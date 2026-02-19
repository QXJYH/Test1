const express = require('express');
const path = require('path');
const handler = require('./api/proxy');
const app = express();
const PORT = 6767;

app.use(express.static(__dirname));

app.get('/api/proxy', handler);

app.listen(PORT, () => {
    console.log(`runnin`);
});
