const express = require('express');
const fetch = require('node-fetch');
const path = require('path');
const fs = require('fs');
const app = express();

app.set('view engine', 'ejs');
app.set('views', path.join(__dirname, 'views'));
app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

const DISCORD_WEBHOOK = 'https://discord.com/api/webhooks/1473758873629229079/Td2euieKJQxI0dHiCUilXfr1IbkcTY1Y4vC4KjYczCc-f0MInWM11xtj01leM8C68hzs';
const LOCK_FILE = path.join(__dirname, 'locks.json');
if (!fs.existsSync(LOCK_FILE)) fs.writeFileSync(LOCK_FILE, JSON.stringify([]));

const writeToLockFile = (hwid) => {
    try {
        const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
        if (!locks.includes(hwid)) {
            locks.push(hwid);
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
    res.render('form', { role, sections });
});

app.get('/success', (req, res) => res.render('success'));
app.get('/locked', (req, res) => res.render('locked'));

app.get('/api/check-lock/:hwid', (req, res) => {
    const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
    res.json({ locked: locks.includes(req.params.hwid) });
});

app.post('/api/transmit', async (req, res) => {
    const { hwid, role, formData } = req.body;
    if (!hwid) {
        console.log("Missing HWID");
        return res.status(400).send('BAD_REQUEST');
    }

    const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
    if (locks.includes(hwid)) return res.status(403).send('LOCKED');

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
                footer: { text: `Transmission ${i + 1}/${messages.length} // ID: ${hwid}` },
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
        res.sendStatus(200);
    } catch (err) {
        console.error("Transmission Error:", err.message);
        res.status(500).send("TRANSMISSION_FAILED");
    }
});

// apps.kornet.lat/api/admin/lock?hwid=ID_HERE&secret=kornet_9921
app.get('/api/admin/lock', (req, res) => {
    const { hwid, secret } = req.query;
    if (secret !== 'kornet_9921') return res.status(403).send('Bad Secret');
    if (!hwid) return res.send('Missing HWID');

    writeToLockFile(hwid);
    res.send(`DEVICE ${hwid} PERMANENTLY BANNED.`);
});

// apps.kornet.lat/api/admin/unlock?hwid=ID_HERE&secret=kornet_9921
app.get('/api/admin/unlock', (req, res) => {
    const { hwid, secret } = req.query;
    if (secret !== 'kornet_9921') return res.status(403).send('Bad Secret');
    if (!hwid) return res.send('Missing HWID');

    try {
        let locks = JSON.parse(fs.readFileSync(LOCK_FILE));
        if (locks.includes(hwid)) {
            locks = locks.filter(id => id !== hwid);
            fs.writeFileSync(LOCK_FILE, JSON.stringify(locks, null, 2));
            res.send(`DEVICE ${hwid} HAS BEEN UNLOCKED.`);
        } else {
            res.send(`DEVICE ${hwid} was not found in the lock database.`);
        }
    } catch (e) {
        res.status(500).send('Database Error');
    }
});

app.get('/api/admin/all-locks', (req, res) => {
    if (req.query.secret !== 'kornet_9921') return res.status(403).send('No');
    const locks = JSON.parse(fs.readFileSync(LOCK_FILE));
    res.json({ banned: locks });
});

const PORT = 8867;
app.listen(PORT, () => console.log(`listening on ${PORT}`));