const axios = require('axios');

// Test different methods to bypass Cloudflare
async function testCloudflareBypass() {
    console.log('🔍 Testing Cloudflare bypass methods...\n');
    
    const url = 'https://kornet.lat/botapi/discord/coinflip';
    const params = { ID: '1302918658804416553', amount: '100' };
    const apiKey = process.env.API_KEY;
    
    const testCases = [
        {
            name: 'Method 1: Standard request',
            headers: { 'KRNT-botAPIkey': apiKey }
        },
        {
            name: 'Method 2: Browser-like headers',
            headers: {
                'KRNT-botAPIkey': apiKey,
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'application/json, text/plain, */*',
                'Accept-Language': 'en-US,en;q=0.9',
                'Accept-Encoding': 'gzip, deflate, br',
                'Connection': 'keep-alive',
                'Referer': 'https://kornet.lat/',
                'Sec-Fetch-Dest': 'empty',
                'Sec-Fetch-Mode': 'cors',
                'Sec-Fetch-Site': 'same-origin'
            }
        },
        {
            name: 'Method 3: POST instead of GET',
            method: 'post',
            headers: { 'KRNT-botAPIkey': apiKey },
            data: params
        }
    ];
    
    for (const test of testCases) {
        console.log(`\n${test.name}:`);
        try {
            const config = {
                url,
                method: test.method || 'get',
                headers: test.headers,
                params: test.method !== 'post' ? params : undefined,
                data: test.data,
                timeout: 10000
            };
            
            const response = await axios(config);
            console.log(`   Status: ${response.status}`);
            
            if (typeof response.data === 'string' && response.data.includes('<!DOCTYPE html>')) {
                console.log('   ❌ Cloudflare blocked (HTML response)');
            } else {
                console.log('   ✅ Success! Response:', response.data);
                break; // Stop if one method works
            }
        } catch (error) {
            console.log(`   ❌ Failed: ${error.message}`);
        }
    }
}

testCloudflareBypass();