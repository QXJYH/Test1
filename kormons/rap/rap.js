const MAX_USER_ID = 1445, EXTRA_IDS = [4444, 7777, 67677, 151515, 	676767, 12313213, 20396599], EXCLUDED_USER_IDS = [12];
const CACHE_KEY = "rap_leaderboard_cache_v9";
const CACHE_DURATION = 10 * 60 * 1000, REFRESH_INTERVAL = 10 * 60 * 1000;

const gridEl = document.getElementById("grid");
const loadingEl = document.getElementById("loading");

async function getJSON(url) {
  const res = await fetch(`/api/proxy?url=${encodeURIComponent(url)}`);
  if (!res.ok) throw new Error(`HTTP ${res.status}`);
  return res.json();
}

async function fetchUserData(userId) {
  try {
    const inv = await getJSON(`https://kornet.lat/apisite/inventory/v1/users/${userId}/assets/collectibles`);
    const items = inv?.data || [];
    if (!items.length) return null;

    let totalRAP = 0;
    for (const it of items) totalRAP += Number(it.recentAveragePrice || 0);

    const avatarData = await getJSON(`https://kornet.lat/apisite/thumbnails/v1/users/avatar?userIds=${userId}&size=150x150&format=png`);
    const avatar = avatarData?.data?.[0]?.imageUrl ? `https://kornet.lat${avatarData.data[0].imageUrl}` : null;

    const info = await getJSON(`https://kornet.lat/apisite/users/v1/users/${userId}`);
    return { userId, username: info?.name || "Unknown", totalRAP, avatar };
  } catch {
    return null;
  }
}

function getUserIds() {
  return [...new Set([...Array.from({ length: MAX_USER_ID }, (_, i) => i + 1), ...EXTRA_IDS])]
    .filter(id => !EXCLUDED_USER_IDS.includes(id));
}

function loadCache() {
  try {
    const c = JSON.parse(localStorage.getItem(CACHE_KEY));
    if (c && Date.now() - c.timestamp < CACHE_DURATION && c.data?.length) return c.data;
  } catch {}
  return null;
}

function saveCache(data) {
  localStorage.setItem(CACHE_KEY, JSON.stringify({ timestamp: Date.now(), data }));
}

function renderLeaderboard(data) {
  gridEl.innerHTML = "";
  loadingEl.style.display = "none";

  if (!data.length) {
    gridEl.innerHTML = `<div style="opacity:.4">No RAP data found.</div>`;
    return;
  }

  data.forEach((u, i) => {
    const div = document.createElement("div");
    div.className = "card";
    div.style.cursor = "pointer";

    div.addEventListener("click", () => {
      window.open(
        `https://kornet.lat/users/${u.userId}/profile`,
        "_blank",
        "noopener"
      );
    });

    div.innerHTML = `
      <div class="rank">#${i + 1}</div>
      ${u.avatar ? `<img src="${u.avatar}">` : ""}
      <div class="name">${u.username}</div>
      <div class="rap">R$${u.totalRAP.toLocaleString()}</div>
    `;
    gridEl.appendChild(div);
  });
}

async function loadLeaderboard() {
  const cached = loadCache();
  if (cached) renderLeaderboard(cached);
  else loadingEl.style.display = "block";

  const ids = getUserIds();
  const results = [];
  const batch = await Promise.allSettled(ids.map(fetchUserData));
  batch.forEach(r => { if (r.status === "fulfilled" && r.value) results.push(r.value); });
  results.sort((a, b) => b.totalRAP - a.totalRAP);
  saveCache(results);
  renderLeaderboard(results);
}

// Auto-refresh
setInterval(loadLeaderboard, REFRESH_INTERVAL);
loadLeaderboard();