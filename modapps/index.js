require('dotenv').config();
const express = require('express');
const fetch = require('node-fetch');
const path = require('path');
const fs = require('fs');
const session = require('express-session');
const rateLimit = require('express-rate-limit');
const Filter = require('bad-words');

const app = express();
app.set('trust proxy', 1); // Crucial for rate limiting behind a proxy (VPS)
const filter = new Filter();

filter.addWords('nigger', 'niggers', 'nigga', 'niggas', 'nword');

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.use(session({
    secret: process.env.SESSION_SECRET,
    resave: false,
    saveUninitialized: false,
    cookie: { secure: false, maxAge: 24 * 60 * 60 * 1000 }
}));

const DISCORD_WEBHOOK = process.env.DISCORD_WEBHOOK_URL;

const transmissionLimiter = rateLimit({
    windowMs: 60 * 60 * 1000, // 1 hour
    max: 2, // Max 2 applications per hour per IP
    message: "APPLICATION RATE LIMIT REACHED. UNAUTHORIZED ACTIVITY LOGGED.",
    standardHeaders: true,
    legacyHeaders: false
});
const LOCK_FILE = path.join(__dirname, 'locks.json');
if (!fs.existsSync(LOCK_FILE)) fs.writeFileSync(LOCK_FILE, JSON.stringify([]));

const writeToLockFile = (id) => {
    try {
        const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
        if (!locks.includes(id)) {
            locks.push(id);
            fs.writeFileSync(LOCK_FILE, JSON.stringify(locks, null, 2));
        }
    } catch (e) {
        console.error("DB error");
    }
};

const ADMIN_QUESTIONS = [
    {
        id: 'id',
        title: '00 // IDENTITY',
        questions: [
            { id: 'discord', label: 'Discord Username', type: 'text', placeholder: 'Discord username here' },
            { id: 'kornet_user', label: 'Kornet Username', type: 'text', placeholder: 'Kornet username here' },
            { id: 'kornet_rank', label: 'Current Rank', type: 'text', placeholder: 'Your current rank here (if any)' },
        ]
    },
    {
        id: 'section1',
        title: '01 // PLATFORM UNDERSTANDING',
        questions: [
            { id: 'q1', label: 'In your own words, explain what a custom Roblox-style platform (like Any Roblox Revivals) is. How is it different from Roblox itself?', type: 'textarea' },
            { id: 'q2', label: 'What do you think are the top 3 responsibilities of an admin on a platform like this, and why?', type: 'textarea' },
            { id: 'q3', label: 'Why is consistency in rule enforcement important for long-term platform survival?', type: 'textarea' },
            { id: 'q4', label: 'What would happen to a platform if staff decisions were based on popularity instead of rules?', type: 'textarea' },
        ]
    },
    {
        id: 'section2',
        title: '02 // TECHNICAL AWARENESS',
        questions: [
            { id: 'q5', label: 'A user reports they cannot log in. List three possible causes that are not related to their internet.', type: 'textarea' },
            { id: 'q6', label: 'Why is it dangerous to give staff more permissions than they actually need?', type: 'textarea' },
            { id: 'q7', label: 'Explain what an API is in simple terms, and give one example of how a platform might use it.', type: 'textarea' },
            { id: 'q8', label: 'Why should updates or changes be tested before being released to all users?', type: 'textarea' },
        ]
    },
    {
        id: 'section3',
        title: '03 // SECURITY PROTOCOLS',
        questions: [
            { id: 'q9', label: 'Name three realistic security threats to a small online platform.', type: 'textarea' },
            { id: 'q10', label: 'A user is suspected of exploiting the economy or currency system, what steps do you take before punishing them?', type: 'textarea' },
            { id: 'q11', label: 'Why is it important to keep internal staff discussions private?', type: 'textarea' },
            { id: 'q12', label: 'What warning signs might suggest a staff member is abusing their position?', type: 'textarea' },
        ]
    },
    {
        id: 'section4',
        title: '04 // MODERATION PHILOSOPHY',
        questions: [
            { id: 'q13', label: 'A well-known creator breaks a serious rule. Many users defend them. How do you handle this situation?', type: 'textarea' },
            { id: 'q14', label: 'A staff member publicly mocks or insults a user, what actions do you take and why?', type: 'textarea' },
            { id: 'q15', label: 'A banned user claims the punishment was unfair and threatens to damage the platform’s reputation, how do you respond?', type: 'textarea' },
            { id: 'q16', label: 'When should moderation actions be handled privately, and when should they be public? Explain your reasoning.', type: 'textarea' },
        ]
    },
    {
        id: 'section5',
        title: '05 // SCENARIOS',
        questions: [
            { id: 'q17', label: 'The platform starts growing quickly, but moderation quality drops. What steps would you take to fix this?', type: 'textarea' },
            { id: 'q18', label: 'You notice staff are interpreting rules differently, what is the correct way to solve this?', type: 'textarea' },
            { id: 'q19', label: 'If you strongly disagree with a decision made by the owner, how do you handle it without causing problems?', type: 'textarea' },
            { id: 'q20', label: 'Authority corrupts most people, why won’t it corrupt you?', type: 'textarea' },
        ]
    },
    {
        id: 'footer',
        title: '99 // FINAL THOUGHTS',
        questions: [
            { id: 'notes', label: 'Anything else?', type: 'textarea', placeholder: 'Notes' },
        ]
    }
];

const STANDARD_QUESTIONS = [
    {
        id: 'id',
        title: '00 // APPLICATION DATA',
        questions: [
            { id: 'kornet_user', label: 'Kornet Username', type: 'text', placeholder: 'Kornet username here' },
            { id: 'discord', label: 'Discord Username', type: 'text', placeholder: 'Discord username here' },
            { id: 'experience', label: 'Experience', type: 'textarea', placeholder: 'Any experience in roblox revivals' },
            { id: 'reason', label: 'Why you want to join us', type: 'textarea', placeholder: 'Explain why you want to join us here' },
            { id: 'revival_roles', label: 'Current staff roles in other revivals', type: 'textarea', placeholder: 'List them here (if any)' },
            { id: 'notes', label: 'Notes', type: 'textarea', placeholder: 'Anything else?' },
        ]
    }
];

app.get('/', (req, res) => res.render('index'));

app.get('/apply/:role', (req, res) => {
    const role = req.params.role;
    const sections = role === 'Administrator' ? ADMIN_QUESTIONS : STANDARD_QUESTIONS;

    const discordUser = req.session.discordUser;

    res.render('form', {
        role,
        sections,
        discordUser: discordUser || null,
        clientId: process.env.DISCORD_CLIENT_ID,
        redirectUri: encodeURIComponent(process.env.DISCORD_REDIRECT_URI)
    });
});

app.get('/success', (req, res) => {
    if (!req.session.justSubmitted) return res.redirect('/');
    res.render('success');
});

app.get('/locked', (req, res) => {
    if (!req.session.isLocked) return res.redirect('/');
    res.render('locked');
});

app.get('/api/check-lock/:hwid', (req, res) => {
    const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
    const isLocked = locks.includes(req.params.hwid);

    const isDiscordLocked = req.session.discordUser && locks.includes(req.session.discordUser.id);

    if (isLocked || isDiscordLocked) {
        req.session.isLocked = true;
    }

    res.json({ locked: isLocked || isDiscordLocked });
});

app.get('/api/discord/login', (req, res) => {
    const url = `https://discord.com/api/oauth2/authorize?client_id=${process.env.DISCORD_CLIENT_ID}&redirect_uri=${encodeURIComponent(process.env.DISCORD_REDIRECT_URI)}&response_type=code&scope=identify`;
    res.redirect(url);
});

app.get('/api/discord/callback', async (req, res) => {
    const { code } = req.query;
    if (!code) return res.redirect('/');

    try {
        const tokenResponse = await fetch('https://discord.com/api/oauth2/token', {
            method: 'POST',
            body: new URLSearchParams({
                client_id: process.env.DISCORD_CLIENT_ID,
                client_secret: process.env.DISCORD_CLIENT_SECRET,
                code,
                grant_type: 'authorization_code',
                redirect_uri: process.env.DISCORD_REDIRECT_URI,
                scope: 'identify',
            }),
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
            },
        });

        const tokens = await tokenResponse.json();
        if (tokens.error) throw new Error(tokens.error_description);

        const userResponse = await fetch('https://discord.com/api/users/@me', {
            headers: {
                Authorization: `Bearer ${tokens.access_token}`,
            },
        });

        const user = await userResponse.json();

        let kornetUsername = null;
        try {
            const lookupRes = await fetch(`${process.env.API_BASE_URL || 'https://kornet.lat'}/botapi/tickets/user/${user.id}`, {
                headers: {
                    'KRNT-botAPIkey': process.env.API_KEY || '',
                    'User-Agent': 'DiscordBot/1.0'
                }
            });

            if (lookupRes.ok) {
                const lookupData = await lookupRes.json();
                kornetUsername = lookupData.username || null;
            }
        } catch (e) {
            console.error("Kornet Lookup Failed:", e.message);
        }

        req.session.discordUser = {
            id: user.id,
            username: user.username,
            discriminator: user.discriminator,
            avatar: user.avatar,
            global_name: user.global_name,
            kornet_username: kornetUsername
        };

        res.send('<script>window.opener.postMessage({ type: "discord-verify", user: ' + JSON.stringify(req.session.discordUser) + ' }, "*"); window.close();</script>');
    } catch (err) {
        console.error("Discord Auth Error:", err);
        res.status(500).send("Discord Authentication Failed");
    }
});

app.post('/api/transmit', transmissionLimiter, async (req, res) => {
    const { hwid, role, formData } = req.body;

    if (!req.session.discordUser || !req.session.discordUser.id || !req.session.discordUser.kornet_username) {
        return res.status(401).send('IDENTITY_VERIFICATION_REQUIRED');
    }

    if (req.session.hasSubmitted) {
        return res.status(403).send('ALREADY_SUBMITTED');
    }

    const VALID_ROLES = ['Administrator', 'Moderator', 'Asset Creator', 'Asset Mod'];
    if (!VALID_ROLES.includes(role)) {
        console.log(`[SECURITY] Fake role detected: ${role} from ID: ${req.session.discordUser.id}`);
        return res.status(400).send('INVALID_ROLE');
    }

    formData.discord = req.session.discordUser.username;
    formData.kornet_user = req.session.discordUser.kornet_username;

    const payloadContent = JSON.stringify(formData).toLowerCase();
    const bannedPatterns = ['nigger', 'nigga', 'nigg', 'faggot', 'kike', 'retard'];
    const hasSlur = bannedPatterns.some(p => payloadContent.includes(p)) || filter.isProfane(payloadContent);

    if (hasSlur) {
        console.log(`[SECURITY] PROFANITY ATTEMPT BLOCKED from Discord ID: ${req.session.discordUser.id}`);
        writeToLockFile(hwid);
        writeToLockFile(req.session.discordUser.id);
        req.session.isLocked = true;
        return res.status(400).send('PROFANITY_DETECTED');
    }

    const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
    if (locks.includes(hwid) || locks.includes(req.session.discordUser.id)) return res.status(403).send('LOCKED');

    const sections = role === 'Administrator' ? ADMIN_QUESTIONS : STANDARD_QUESTIONS;
    const allFields = [];
    sections.forEach(s => {
        allFields.push({ name: `━━━ ${s.title} ━━━`, value: '\u200B', inline: false });
        s.questions.forEach(q => {
            const val = String(formData[q.id] || "No response.");
            allFields.push({ name: q.label, value: val.substring(0, 1024), inline: false });
        });
    });

    const messages = [];
    let currentFields = [];
    let currentChars = 0;

    allFields.forEach(f => {
        const fieldChars = f.name.length + f.value.length;
        if (currentChars + fieldChars > 5000 || currentFields.length >= 20) {
            messages.push(currentFields);
            currentFields = [];
            currentChars = 0;
        }
        currentFields.push(f);
        currentChars += fieldChars;
    });
    if (currentFields.length > 0) messages.push(currentFields);

    try {
        for (let i = 0; i < messages.length; i++) {
            const embed = {
                title: i === 0 ? `NEW APPLICATION: ${role}` : `APPLICATION CONTINUED (Part ${i + 1})`,
                color: 3066993,
                fields: messages[i],
                author: {
                    name: `${req.session.discordUser.username} (${req.session.discordUser.id})`,
                    icon_url: req.session.discordUser.avatar ? `https://cdn.discordapp.com/avatars/${req.session.discordUser.id}/${req.session.discordUser.avatar}.png` : null
                },
                footer: { text: `Transmission ${i + 1}/${messages.length} // HWID: ${hwid}` },
                timestamp: i === 0 ? new Date().toISOString() : null
            };

            const body = {
                username: "Kornet Applications",
                avatar_url: "https://kornet.lat/favicon.ico",
                embeds: [embed]
            };

            const dRes = await fetch(DISCORD_WEBHOOK, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body)
            });

            if (!dRes.ok) {
                const errorText = await dRes.text();
                throw new Error(`Discord ${dRes.status}: ${errorText}`);
            }
        }

        writeToLockFile(hwid);
        writeToLockFile(req.session.discordUser.id);
        req.session.isLocked = true;
        req.session.hasSubmitted = true;
        req.session.justSubmitted = true;
        res.sendStatus(200);
    } catch (err) {
        console.error("Transmission Error:", err.message);
        res.status(500).send("TRANSMISSION_FAILED");
    }
});

// apps.kornet.lat/api/admin/lock?hwid=ID_HERE&secret=kornet_9921
app.get('/api/admin/lock', (req, res) => {
    const { hwid, secret } = req.query;
    if (secret !== process.env.SESSION_SECRET) return res.status(403).send('nah');
    if (!hwid) return res.send('Missing HWID');

    writeToLockFile(hwid);
    res.send(`ID ${hwid} PERMANENTLY BANNED.`);
});

// apps.kornet.lat/api/admin/unlock?hwid=ID_HERE&secret=kornet_9921
app.get('/api/admin/unlock', (req, res) => {
    const { hwid, secret } = req.query;
    if (secret !== process.env.SESSION_SECRET) return res.status(403).send('nah');
    if (!hwid) return res.send('Missing HWID');

    try {
        let locks = JSON.parse(fs.readFileSync(LOCK_FILE));
        if (locks.includes(hwid)) {
            locks = locks.filter(id => id !== hwid);
            fs.writeFileSync(LOCK_FILE, JSON.stringify(locks, null, 2));
            res.send(`ID ${hwid} HAS BEEN UNLOCKED.`);
        } else {
            res.send(`ID ${hwid} was not found in the lock database.`);
        }
    } catch (e) {
        res.status(500).send('Database Error');
    }
});

app.get('/api/admin/all-locks', (req, res) => {
    if (req.query.secret !== process.env.SESSION_SECRET) return res.status(403).send('dawg..');
    const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
    res.json({ banned: locks });
});

const PORT = 8867;
app.listen(PORT, () => console.log(`listening on ${PORT}`));