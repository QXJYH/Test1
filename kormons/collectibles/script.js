const API = '/api/proxy?url=';
async function getJSON(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(res.status);
  return res.json();
}
function comma(x) {
  return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',');
}

// read params / cache
const params = new URLSearchParams(location.search);
let currentUserId = params.get('user') || ""; // ← no redirect here

// DOM refs (once)
const avatarEl   = document.getElementById('avatar-wrap');
const dispEl     = document.getElementById('displayName');
const userEl     = document.getElementById('username');
const descEl     = document.getElementById('desc');
const statusEl   = document.getElementById('status');
const profileA   = document.getElementById('profileLink');
const gridEl     = document.getElementById('grid');
const loadingEl  = document.getElementById('loading');
const titleEl    = document.getElementById('collectiblesTitle');
const countEl    = document.getElementById('count');
const formEl     = document.getElementById('userForm');
const inputEl    = document.getElementById('userIdInput');

// ----------------------------
// Load user profile
// ----------------------------
async function loadUser(id) {
  try {
    // clear UI quickly
    dispEl.textContent = '—';
    userEl.textContent = '@—';
    statusEl.textContent = '—';
    descEl.textContent = '';
    avatarEl.innerHTML = `<span style="color:#9aa0aa">Loading user…</span>`;

    // info
    const info = await getJSON(`${API}https://kornet.lat/apisite/users/v1/users/${id}`);
    dispEl.textContent = info.displayName || 'Unknown';
    userEl.textContent = '@' + (info.name || id);
    descEl.textContent = info.description || '';

    // status
    try {
      const s = await getJSON(`${API}https://kornet.lat/apisite/users/v1/users/${id}/status`);
      const statusText = s?.status || s?.data?.status || s?.text || '—';
      statusEl.textContent = statusText.trim() !== '' ? statusText : '—';
      statusEl.style.color = '#9ca3af';
      statusEl.style.fontSize = '0.9rem';
    } catch {
      statusEl.textContent = '—';
      statusEl.style.color = '#9ca3af';
      statusEl.style.fontSize = '0.9rem';
    }

    // avatar
    const avatarData = await getJSON(
      `${API}https://kornet.lat/apisite/thumbnails/v1/users/avatar?userIds=${id}&size=420x420&format=png`
    );
    let avatarUrl = avatarData?.data?.[0]?.imageUrl || '';
    if (avatarUrl.startsWith('/')) avatarUrl = `https://kornet.lat${avatarUrl}`;
    avatarEl.innerHTML = `<img src="${avatarUrl}" alt="Avatar" style="width:100%;border-radius:12px;">`;

    // profile link
    profileA.href = `https://kornet.lat/users/${id}/profile`;
  } catch (err) {
    console.error('User load failed:', err);
    avatarEl.innerHTML = `<p style="color:#888;text-align:center;">Error loading user</p>`;
    dispEl.textContent = userEl.textContent = descEl.textContent = statusEl.textContent = '—';
  }
}

// ----------------------------
// Load collectibles for user
// ----------------------------
async function loadCollectibles(id) {
  try {
    gridEl.innerHTML = '';
    loadingEl.textContent = 'Loading collectibles…';
    loadingEl.style.display = 'block';
    countEl.textContent = '0';
    titleEl.textContent = 'Collectibles';

    const res = await getJSON(`${API}https://kornet.lat/apisite/inventory/v1/users/${id}/assets/collectibles`);
    const raw = res?.data || [];

    if (!raw.length) {
      loadingEl.textContent = 'No collectibles found';
      return;
    }

    // group by assetId (for quantity)
    const grouped = new Map();
    let totalRap = 0;

    for (const it of raw) {
      const aid = it.assetId;
      totalRap += Number(it.recentAveragePrice || 0);
      if (!grouped.has(aid)) grouped.set(aid, { item: it, qty: 0 });
      grouped.get(aid).qty += 1;
    }

    gridEl.innerHTML = '';
    for (const { item, qty } of grouped.values()) {
      const thumb = `https://kornet.lat/thumbs/asset.ashx?assetId=${item.assetId}&width=420&height=420&format=png`;
      const div = document.createElement('div');
      div.className = 'card';
      div.style.cursor = 'pointer';
      div.addEventListener("click", () => {
        window.open(
          `https://kornet.lat/catalog/${item.assetId}/${encodeURIComponent(item.name.replace(/\s+/g, '-'))}`,
          "_blank",
          "noopener"
        );
      });
      div.innerHTML = `
        <div class="thumb-wrap">
          <img class="thumb" src="${thumb}" alt="${item.name || 'Item'}">
          ${qty > 1 ? `<div class="item-count">×${qty}</div>` : ''}
        </div>
        <div class="body">
          <p class="name">${item.name || 'Unknown'}</p>
          <p class="meta">RAP: ${comma(Number(item.recentAveragePrice || 0))}</p>
        </div>
      `;
      gridEl.appendChild(div);
    }

    titleEl.textContent = `Collectibles (Total RAP: ${comma(totalRap)})`;
    countEl.textContent = raw.length; // total instances
    loadingEl.style.display = 'none';
  } catch (e) {
    console.error(e);
    loadingEl.textContent =
      'Collectibles are not available ( Inventory Private or Kornet is down. (403) ).';
  }
}

// ----------------------------
// Boot
// ----------------------------
document.addEventListener('DOMContentLoaded', () => {
  // 1) If we have ?user= load it
  if (currentUserId) {
    inputEl && (inputEl.value = currentUserId);
    loadUser(currentUserId);
    loadCollectibles(currentUserId);
  } else {
    // 2) otherwise, try last seen user OR keep the page idle letting you type
    const saved = localStorage.getItem('last_user_id');
    if (saved) {
      currentUserId = saved;
      inputEl && (inputEl.value = saved);
      history.replaceState({ user: saved }, '', `${location.pathname}?user=${saved}`);
      loadUser(saved);
      loadCollectibles(saved);
    } else {
      // keep page visible to type an ID
      inputEl && inputEl.focus();
      avatarEl.innerHTML = `<span style="color:#9aa0aa">Enter a User ID and press Load</span>`;
      loadingEl.textContent = 'Waiting for a user ID…';
    }
  }
});

// ----------------------------
// Search form
// ----------------------------
if (formEl && inputEl) {
  formEl.addEventListener('submit', async (e) => {
    e.preventDefault();
    const id = inputEl.value.trim();
    if (!id) return alert('Please enter a valid User ID.');

    // update URL (no reload)
    history.pushState({ user: id }, '', `/collectibles?user=${encodeURIComponent(id)}`);

    // load data
    await Promise.all([loadUser(id), loadCollectibles(id)]);

    // persist
    localStorage.setItem('last_user_id', id);
    currentUserId = id;
  });

  // back/forward navigation support
  window.addEventListener('popstate', (e) => {
    const id = e.state?.user || new URLSearchParams(location.search).get('user');
    if (!id) return;
    inputEl.value = id;
    loadUser(id);
    loadCollectibles(id);
    currentUserId = id;
  });
}
