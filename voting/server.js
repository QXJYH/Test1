require('dotenv').config();
const express = require('express');
const axios = require('axios');
const path = require('path');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const crypto = require('crypto');
const cookieParser = require('cookie-parser');
const session = require('express-session');
const SQLiteStore = require('connect-sqlite3')(session);
const { categories, games } = require('./data');

const app = express();
const db = new sqlite3.Database('./votes.db');

const ADMIN_IDS = [
    '1302918658804416553',
    '1175062354199855104',
    '1123009823676575764'
];

app.use(session({
    store: new SQLiteStore({ db: 'sessions.db' }),
    secret: process.env.SESSION_SECRET || 'fallback-secret',
    resave: false,
    saveUninitialized: false,
    cookie: {
        httpOnly: true,
        secure: process.env.NODE_ENV === 'production',
        sameSite: 'strict',
        maxAge: 1000 * 60 * 60 * 24 * 7
    }
}));

function makeAdminToken(password) {
    return crypto
        .createHmac('sha256', process.env.SESSION_SECRET || 'fallback-secret')
        .update(password)
        .digest('hex');
}

function requireAdmin(req, res, next) {
    if (!req.session.userId) {
        return res.status(401).send('Not authenticated');
    }
    
    if (!ADMIN_IDS.includes(req.session.userId)) {
        return res.status(403).send('Not authorized');
    }
    
    next();
}

app.use(express.json());
app.use(cors({
    origin: process.env.FRONTEND_URL || 'http://localhost:3000',
    credentials: true
}));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

db.serialize(() => {
    db.run(`CREATE TABLE IF NOT EXISTS votes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        discord_id TEXT NOT NULL,
        category TEXT NOT NULL,
        game TEXT NOT NULL,
        UNIQUE(discord_id, category)
    )`);
    db.run(`CREATE TABLE IF NOT EXISTS users (
        discord_id TEXT PRIMARY KEY,
        username TEXT NOT NULL,
        avatar TEXT
    )`);
});

app.post('/api/admin/login', (req, res) => {
    const { password } = req.body;
    
    if (!req.session.userId) {
        return res.status(401).json({ error: 'Not authenticated' });
    }
    
    if (!ADMIN_IDS.includes(req.session.userId)) {
        return res.status(403).json({ error: 'Not authorized' });
    }
    
    if (password !== process.env.ADMIN_PASSWORD) {
        return res.status(403).json({ error: 'Incorrect password' });
    }
    
    const token = makeAdminToken(password);
    res.cookie('admin_token', token, {
        httpOnly: true,
        sameSite: 'strict',
        maxAge: 1000 * 60 * 60 * 6
    });
    
    db.get(`SELECT username FROM users WHERE discord_id = ?`, [req.session.userId], (err, user) => {
        if (err || !user) {
            return res.json({ ok: true, username: 'Admin' });
        }
        res.json({ ok: true, username: user.username });
    });
});

app.get('/api/admin/check', (req, res) => {
    if (!req.session.userId) {
        return res.status(401).json({ error: 'Not authenticated' });
    }
    
    if (!ADMIN_IDS.includes(req.session.userId)) {
        return res.status(403).json({ error: 'Not authorized' });
    }
    
    db.get(`SELECT username FROM users WHERE discord_id = ?`, [req.session.userId], (err, user) => {
        if (err || !user) {
            return res.json({ authenticated: true, username: 'Admin' });
        }
        res.json({ authenticated: true, username: user.username });
    });
});

app.get('/admin', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'admin.html'));
});

app.get('/api/admin/results', requireAdmin, (req, res) => {
    db.all(`SELECT category, game, COUNT(*) as counts FROM votes GROUP BY category, game`, (err, stats) => {
        if (err) return res.status(500).send(err.message);
        db.all(`SELECT v.discord_id,
                       COALESCE(u.username, 'Unknown') as username,
                       u.avatar,
                       v.category,
                       v.game
                FROM votes v
                LEFT JOIN users u ON v.discord_id = u.discord_id
                ORDER BY v.id DESC`, (err, voters) => {
            if (err) return res.status(500).send(err.message);
            res.json({ stats, voters });
        });
    });
});

app.post('/api/admin/logout', (req, res) => {
    res.clearCookie('admin_token');
    res.clearCookie('connect.sid');
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ error: 'Could not log out' });
        }
        res.json({ ok: true });
    });
});

app.get('/api/games', (req, res) => {
    res.json({ categories, games });
});

app.get('/api/auth/login', (req, res) => {
    const url = `https://discord.com/api/oauth2/authorize?client_id=${process.env.DISCORD_CLIENT_ID}&redirect_uri=${encodeURIComponent(process.env.DISCORD_REDIRECT_URI)}&response_type=code&scope=identify`;
    res.redirect(url);
});

app.get('/api/auth/callback', async (req, res) => {
    const { code } = req.query;
    if (!code) return res.send('No code provided');

    try {
        const tokenResponse = await axios.post('https://discord.com/api/oauth2/token', new URLSearchParams({
            client_id: process.env.DISCORD_CLIENT_ID,
            client_secret: process.env.DISCORD_CLIENT_SECRET,
            grant_type: 'authorization_code',
            code,
            redirect_uri: process.env.DISCORD_REDIRECT_URI,
        }), {
            headers: { 'Content-Type': 'application/x-www-form-urlencoded' }
        });

        const userResponse = await axios.get('https://discord.com/api/users/@me', {
            headers: { Authorization: `Bearer ${tokenResponse.data.access_token}` }
        });

        const user = userResponse.data;
        const handle = user.username;

        let avatarUrl;
        if (user.avatar) {
            const ext = user.avatar.startsWith('a_') ? 'gif' : 'png';
            avatarUrl = `https://cdn.discordapp.com/avatars/${user.id}/${user.avatar}.${ext}?size=128`;
        } else {
            const idx = user.discriminator && user.discriminator !== '0'
                ? parseInt(user.discriminator) % 5
                : (BigInt(user.id) >> 22n) % 6n;
            avatarUrl = `https://cdn.discordapp.com/embed/avatars/${idx}.png`;
        }

        db.run(`INSERT INTO users (discord_id, username, avatar) VALUES (?, ?, ?)
                ON CONFLICT(discord_id) DO UPDATE SET username=excluded.username, avatar=excluded.avatar`,
            [user.id, handle, avatarUrl]);

        req.session.userId = user.id;
        req.session.username = handle;
        req.session.avatar = avatarUrl;
        
        res.redirect('/');
    } catch (err) {
        console.error(err);
        res.send('Authentication failed');
    }
});

app.get('/api/auth/me', (req, res) => {
    if (req.session.userId) {
        db.get(`SELECT discord_id, username, avatar FROM users WHERE discord_id = ?`, 
            [req.session.userId], (err, user) => {
            if (err || !user) {
                return res.json({ authenticated: false });
            }
            res.json({
                authenticated: true,
                user: {
                    id: user.discord_id,
                    username: user.username,
                    avatar: user.avatar
                }
            });
        });
    } else {
        res.json({ authenticated: false });
    }
});

app.post('/api/auth/logout', (req, res) => {
    req.session.destroy((err) => {
        if (err) {
            return res.status(500).json({ error: 'Could not log out' });
        }
        res.clearCookie('connect.sid');
        res.json({ ok: true });
    });
});

app.post('/api/vote', (req, res) => {
    const discord_id = req.session.userId;
    const { category, game } = req.body;
    
    if (!discord_id) return res.status(401).send('Not authenticated');
    if (!category || !game) return res.status(400).send('Missing data');

    db.run(`INSERT INTO votes (discord_id, category, game) VALUES (?, ?, ?)`, [discord_id, category, game], (err) => {
        if (err) {
            if (err.message.includes('UNIQUE constraint failed')) {
                return res.status(400).send('You already voted in this category');
            }
            return res.status(500).send(err.message);
        }
        res.send('Vote cast successfully!');
    });
});

app.get('/api/user/votes', (req, res) => {
    const discord_id = req.session.userId;
    if (!discord_id) return res.status(401).send('Not authenticated');
    
    db.all(`SELECT category, game FROM votes WHERE discord_id = ?`, [discord_id], (err, rows) => {
        if (err) return res.status(500).send(err.message);
        const votes = {};
        rows.forEach(r => votes[r.category] = r.game);
        res.json(votes);
    });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});