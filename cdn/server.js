const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();
const port = 6769;

app.get('/', (req, res) => {
    res.send('what are u doing here');
});

app.get('/*path', (req, res) => {
    const filesfolder = path.join(__dirname, 'files', req.path);
    if (fs.existsSync(filesfolder)) {
        res.download(filesfolder);
        console.log(`giving the guy ${filesfolder}`)
    }
});

app.listen(port, 'localhost', () => {
    console.log(`hell yea it started at http://localhost:${port}`);
});