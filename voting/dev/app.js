(function() {
    'use strict';
    
    // Disable right-click context menu
    document.addEventListener('contextmenu', function(e) {
        e.preventDefault();
        return false;
    });
    
    // Disable text selection
    document.addEventListener('selectstart', function(e) {
        e.preventDefault();
        return false;
    });
    
    // Disable drag and drop
    document.addEventListener('dragstart', function(e) {
        e.preventDefault();
        return false;
    });
    
    // Disable F12, Ctrl+Shift+I, Ctrl+Shift+J, Ctrl+U, Ctrl+S, Ctrl+A, Ctrl+P
    document.addEventListener('keydown', function(e) {
        // F12 key
        if (e.keyCode === 123) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+Shift+I (Developer Tools)
        if (e.ctrlKey && e.shiftKey && e.keyCode === 73) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+Shift+J (Console)
        if (e.ctrlKey && e.shiftKey && e.keyCode === 74) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+U (View Source)
        if (e.ctrlKey && e.keyCode === 85) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+S (Save Page)
        if (e.ctrlKey && e.keyCode === 83) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+A (Select All)
        if (e.ctrlKey && e.keyCode === 65) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+P (Print)
        if (e.ctrlKey && e.keyCode === 80) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+Shift+C (Inspect Element)
        if (e.ctrlKey && e.shiftKey && e.keyCode === 67) {
            e.preventDefault();
            return false;
        }
        
        // Ctrl+Shift+K (Web Console)
        if (e.ctrlKey && e.shiftKey && e.keyCode === 75) {
            e.preventDefault();
            return false;
        }
    });
    
    // Disable copy, cut, paste
    document.addEventListener('copy', function(e) {
        e.preventDefault();
        return false;
    });
    
    document.addEventListener('cut', function(e) {
        e.preventDefault();
        return false;
    });
    
    document.addEventListener('paste', function(e) {
        e.preventDefault();
        return false;
    });
    
    // Disable developer tools detection
    let devtools = {
        open: false,
        orientation: null
    };
    
    const threshold = 160;
    
    setInterval(function() {
        if (window.outerHeight - window.innerHeight > threshold || 
            window.outerWidth - window.innerWidth > threshold) {
            if (!devtools.open) {
                devtools.open = true;
                console.clear();
                console.log('%cDeveloper Tools Detected!', 'color: red; font-size: 50px; font-weight: bold;');
                console.log('%cThis website is protected. Please close developer tools.', 'color: red; font-size: 20px;');
            }
        } else {
            devtools.open = false;
        }
    }, 500);
    
    // Disable console methods
    (function() {
        const noop = function() {};
        const methods = ['log', 'debug', 'info', 'warn', 'error', 'assert', 'clear', 'count', 'dir', 'dirxml', 'group', 'groupCollapsed', 'groupEnd', 'profile', 'profileEnd', 'time', 'timeEnd', 'timeStamp', 'trace'];
        
        for (let i = 0; i < methods.length; i++) {
            console[methods[i]] = noop;
        }
    })();
    
    console.log('%cWarning!', 'color: red; font-size: 30px; font-weight: bold;');
    console.log('%cThis is a browser feature intended for developers. Do not enter any code here.', 'color: red; font-size: 16px;');
    
})();

(function () {
    let currentUser = null;
    let userVotes = {};
    let typedBuffer = "";

    const votingContainer = document.getElementById('voting-categories');
    const loginBtn = document.getElementById('discord-login-btn');
    const notificationContainer = document.getElementById('notification-container');

    function showNotification(message, type = 'success') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerText = message;
        notificationContainer.appendChild(notification);
        setTimeout(() => notification.classList.add('show'), 10);
        setTimeout(() => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        }, 3000);
    }

    async function checkAuth() {
        try {
            const res = await fetch('/api/auth/me', {
                credentials: 'include'
            });
            const data = await res.json();
            
            if (data.authenticated) {
                currentUser = data.user;
                loginBtn.innerText = currentUser.username;
                loginBtn.disabled = true;
                fetchUserVotes();
            }
        } catch (err) {
            console.error(err);
        }
    }

    async function fetchUserVotes() {
        try {
            const res = await fetch('/api/user/votes', {
                credentials: 'include'
            });
            if (res.ok) {
                userVotes = await res.json();
                Object.keys(userVotes).forEach(cat => updateVoteUI(cat, userVotes[cat]));
            }
        } catch (err) {
            console.error(err);
        }
    }

    async function init() {
        try {
            const res = await fetch('/api/games');
            const data = await res.json();
            renderCategories(data.categories, data.games);
            await checkAuth();
        } catch (err) {
            console.error(err);
        }
    }

    function renderCategories(categories, games) {
        votingContainer.innerHTML = "";
        categories.forEach(category => {
            const section = document.createElement('section');
            section.className = 'category-section';
            section.innerHTML = `
                <div class="category-header">
                    <h2 class="category-title">${category}</h2>
                    <div class="category-line"></div>
                </div>
                <div class="nominees-grid" id="grid-${category.replace(/\s+/g, '-')}"></div>
            `;
            votingContainer.appendChild(section);

            const grid = section.querySelector('.nominees-grid');
            games.forEach(gameObj => {
                const game = gameObj.name;
                const placeId = gameObj.id;
                const slug = game.toLowerCase().replace(/\s+/g, '-');
                const card = document.createElement('div');
                card.className = 'nominee-card';
                card.innerHTML = `
                    <img class="nominee-icon" src="assets/icons/${slug}.png" alt="${game}">
                    <div class="nominee-info">
                        <h3><a href="https://kornet.lat/games/${placeId}/--" target="_blank" class="game-link">${game}</a></h3>
                        <button class="vote-btn" data-category="${category}" data-game="${game}">Vote</button>
                    </div>
                `;
                grid.appendChild(card);
            });
        });

        if (currentUser) {
            Object.keys(userVotes).forEach(cat => updateVoteUI(cat, userVotes[cat]));
        }

        document.querySelectorAll('.vote-btn').forEach(btn => {
            btn.addEventListener('click', onVoteClick);
        });
    }

    async function onVoteClick(e) {
        if (!currentUser) return showNotification("You must verify with Discord first!", "error");

        const category = e.target.dataset.category;
        const game = e.target.dataset.game;

        if (userVotes[category]) return showNotification("You already voted in this category!", "error");

        const res = await fetch('/api/vote', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            credentials: 'include',
            body: JSON.stringify({ category, game })
        });

        if (res.ok) {
            userVotes[category] = game;
            updateVoteUI(category, game);
            showNotification(`Voted for ${game}!`, "success");
        } else {
            const err = await res.text();
            showNotification(err, "error");
        }
    }

    function updateVoteUI(category, game) {
        document.querySelectorAll(`.vote-btn[data-category="${category}"]`).forEach(b => {
            if (b.dataset.game === game) {
                b.innerText = "Voted ✓";
                b.classList.add('voted');
                b.closest('.nominee-card').classList.add('selected');
            }
            b.disabled = true;
        });
    }

    window.addEventListener('keydown', (e) => {
        typedBuffer += e.key.toLowerCase();
        if (typedBuffer.endsWith("iamowner")) {
            window.location.href = "/admin";
            typedBuffer = "";
        }
        if (typedBuffer.length > 20) typedBuffer = typedBuffer.slice(-20);
    });

    loginBtn.addEventListener('click', () => {
        window.location.href = "/api/auth/login";
    });

    init();
})();