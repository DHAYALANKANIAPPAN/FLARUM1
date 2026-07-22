const API_BASE_URL = window.location.origin + '/api';

let currentFilter = 'recent';
let currentUser = JSON.parse(localStorage.getItem('flarum_user')) || null;
let authToken = localStorage.getItem('flarum_token') || null;

document.addEventListener('DOMContentLoaded', () => {
    updateAuthUI();
    loadDiscussions();
});

// Update Header Authentication UI
function updateAuthUI() {
    const authSection = document.getElementById('auth-section');
    if (currentUser && authToken) {
        authSection.innerHTML = `
            <span class="user-badge">${currentUser.isAdmin ? '👑 Admin' : '👤'} ${currentUser.username}</span>
            <button class="btn-secondary" onclick="handleLogout()">Logout</button>
        `;
    } else {
        authSection.innerHTML = `
            <button class="btn-secondary" onclick="openModal('login-modal')">Sign In</button>
            <button class="btn-primary" onclick="openModal('register-modal')">Sign Up</button>
        `;
    }
}

// Switch between Feed Tabs (Recent, Best Answer, Pinned)
function loadFilter(filter) {
    currentFilter = filter;
    document.querySelectorAll('.nav-item').forEach(btn => btn.classList.remove('active'));
    document.querySelector(`[data-filter="${filter}"]`).classList.add('active');

    const titles = {
        'recent': 'Recent Discussions',
        'best-answer': 'Discussions with Best Answer Marked',
        'pinned': 'Pinned Announcements'
    };
    document.getElementById('feed-title').innerText = titles[filter];
    loadDiscussions();
}

// Fetch discussions from Flarum API based on tab
async function loadDiscussions() {
    const feed = document.getElementById('discussions-list');
    feed.innerHTML = '<p class="loading">Loading discussions...</p>';

    let queryParam = '-createdAt'; // Default: Recent
    if (currentFilter === 'pinned') queryParam = '-isSticky';
    if (currentFilter === 'best-answer') queryParam = '-hasBestAnswer';

    try {
        const response = await fetch(`${API_BASE_URL}/discussions?sort=${queryParam}&include=user,firstPost`);
        if (!response.ok) throw new Error('API fetch failed');
        
        const data = await response.json();
        renderFeed(data.data || []);
    } catch (err) {
        feed.innerHTML = '<p class="error-msg">Failed to load discussions from Flarum API.</p>';
    }
}

// Render Discussions Feed with Admin Controls
function renderFeed(discussions) {
    const feed = document.getElementById('discussions-list');
    if (discussions.length === 0) {
        feed.innerHTML = '<p class="empty-msg">No discussions found in this section.</p>';
        return;
    }

    feed.innerHTML = discussions.map(item => {
        const title = item.attributes.title;
        const id = item.id;
        const isSticky = item.attributes.isSticky;
        const hasBestAnswer = item.attributes.hasBestAnswer;

        let badges = '';
        if (isSticky) badges += '<span class="badge pinned">📌 Pinned</span> ';
        if (hasBestAnswer) badges += '<span class="badge best-answer">✅ Best Answer</span> ';

        let adminActions = '';
        if (currentUser && currentUser.isAdmin) {
            adminActions = `
                <button class="btn-delete" onclick="deleteDiscussion('${id}')">🗑️ Delete</button>
            `;
        }

        return `
            <div class="discussion-card">
                <div class="card-header">
                    <h4>${badges}${title}</h4>
                    ${adminActions}
                </div>
            </div>
        `;
    }).join('');
}

// Admin API Action: Delete Discussion
async function deleteDiscussion(discussionId) {
    if (!confirm('Are you sure you want to delete this discussion as an Admin?')) return;

    try {
        const res = await fetch(`${API_BASE_URL}/discussions/${discussionId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Token ${authToken}`,
                'Content-Type': 'application/json'
            }
        });

        if (res.ok) {
            alert('Discussion deleted successfully!');
            loadDiscussions();
        } else {
            alert('Failed to delete discussion. Check admin permissions.');
        }
    } catch (e) {
        alert('Error connecting to backend.');
    }
}

// Login Handler
async function handleLogin(e) {
    e.preventDefault();
    const identification = document.getElementById('login-identification').value;
    const password = document.getElementById('login-password').value;

    try {
        const res = await fetch(`${API_BASE_URL}/token`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ identification, password })
        });

        const data = await res.json();
        if (res.ok) {
            authToken = data.token;
            localStorage.setItem('flarum_token', authToken);

            // Fetch user info & permissions
            const userRes = await fetch(`${API_BASE_URL}/users/${data.userId}`, {
                headers: { 'Authorization': `Token ${authToken}` }
            });
            const userData = await userRes.json();
            
            // Check if user belongs to admin group (Group ID 1 in Flarum)
            const isAdmin = userData.data.relationships?.groups?.data?.some(g => g.id === "1") || false;

            currentUser = {
                id: data.userId,
                username: identification,
                isAdmin: isAdmin
            };

            localStorage.setItem('flarum_user', JSON.stringify(currentUser));
            closeModal('login-modal');
            updateAuthUI();
            loadDiscussions();
        } else {
            alert('Login failed: ' + (data.errors ? data.errors[0].detail : 'Invalid credentials'));
        }
    } catch (err) {
        alert('Login server error.');
    }
}

// User Registration Handler
async function handleRegister(e) {
    e.preventDefault();
    const username = document.getElementById('reg-username').value;
    const email = document.getElementById('reg-email').value;
    const password = document.getElementById('reg-password').value;

    try {
        const res = await fetch(`${API_BASE_URL}/users`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ data: { attributes: { username, email, password } } })
        });

        if (res.ok) {
            alert('Registration successful! Please sign in.');
            closeModal('register-modal');
            openModal('login-modal');
        } else {
            const data = await res.json();
            alert('Registration failed: ' + (data.errors ? data.errors[0].detail : 'Validation error'));
        }
    } catch (err) {
        alert('Registration server error.');
    }
}

// Logout
function handleLogout() {
    localStorage.removeItem('flarum_token');
    localStorage.removeItem('flarum_user');
    currentUser = null;
    authToken = null;
    updateAuthUI();
    loadDiscussions();
}

// Utility Modal Helpers
function openModal(id) { document.getElementById(id).style.display = 'flex'; }
function closeModal(id) { document.getElementById(id).style.display = 'none'; }
