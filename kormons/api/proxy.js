async function handler(req, res) {
  const url = req.query.url;

  if (!url) return res.status(400).json({ error: 'Missing url parameter' });
  if (!url.startsWith('https://kornet.lat/')) {
    return res.status(403).json({ error: 'Only kornet.lat is allowed' });
  }

  try {
    // We'll follow redirects manually to keep the X-Proxy-Secret header
    let nextUrl = url;
    let response;
    let maxRedirects = 5; // avoid infinite loops

    for (let i = 0; i < maxRedirects; i++) {
      response = await fetch(nextUrl, {
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          'Accept': 'application/json',
          'X-Proxy-Secret': 'supersecretkey123'
        },
        redirect: 'manual' // important: don't lose headers on redirect
      });

      if (response.status >= 300 && response.status < 400) {
        // handle redirect manually
        const location = response.headers.get('location');
        if (!location) break;
        // Resolve relative redirects
        nextUrl = new URL(location, nextUrl).toString();
        continue;
      }
      break; // no redirect, exit loop
    }

    if (!response.ok) {
      return res.status(response.status).json({
        error: `Upstream API blocked or returned ${response.status}`
      });
    }

    // Check content type
    const contentType = response.headers.get('content-type') || '';
    if (!contentType.includes('application/json')) {
      const text = await response.text();
      let msg = 'Upstream did not return JSON';
      if (text.includes('Attention Required') || text.includes('Cloudflare')) {
        msg = 'Cloudflare blocked the request';
      }
      return res.status(502).json({ error: msg });
    }

    // Parse JSON safely
    const data = await response.json();

    res.setHeader('Content-Type', 'application/json');
    return res.status(200).json(data);

  } catch (e) {
    console.error('Proxy error:', e);
    return res.status(500).json({ error: 'Failed to fetch upstream API' });
  }
}
module.exports = handler;