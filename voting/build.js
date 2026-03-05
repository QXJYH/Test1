const JavaScriptObfuscator = require('javascript-obfuscator');
const fs = require('fs');
const path = require('path');

const inputPath = path.join(__dirname, 'dev', 'app.js');
const outputPath = path.join(__dirname, 'public', 'app.min.js');

const code = fs.readFileSync(inputPath, 'utf8');

const obfuscated = JavaScriptObfuscator.obfuscate(code, {
    compact: true,
    controlFlowFlattening: true,
    controlFlowFlatteningThreshold: 1,
    deadCodeInjection: true,
    deadCodeInjectionThreshold: 1,
    debugProtection: true,
    debugProtectionInterval: 4000,
    disableConsoleOutput: true,
    identifierNamesGenerator: 'hexadecimal',
    log: false,
    numbersToExpressions: true,
    renameGlobals: true,
    selfDefending: true,
    simplify: true,
    splitStrings: true,
    splitStringsChunkLength: 5,
    stringArray: true,
    stringArrayCallsTransform: true,
    stringArrayEncoding: ['rc4'],
    stringArrayIndexShift: true,
    stringArrayRotate: true,
    stringArrayShuffle: true,
    stringArrayWrappersCount: 5,
    stringArrayWrappersChainedCalls: true,
    stringArrayWrappersParametersMaxCount: 5,
    stringArrayWrappersType: 'function',
    stringArrayThreshold: 1,
    transformObjectKeys: true,
    unicodeEscapeSequence: true
});

fs.writeFileSync(outputPath, obfuscated.getObfuscatedCode(), 'utf8');
console.log('Successfully obfuscated app.js to app.min.js');
