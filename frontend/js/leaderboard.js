document.addEventListener('DOMContentLoaded', fetchLeaderboard);

async function fetchLeaderboard() {
  const tbody = document.getElementById('leaderboardBody');
  try {
    const res = await fetch('/api/users');
    const json = await res.json();

    if (!json.data || json.data.length === 0) {
      tbody.innerHTML = '<tr><td colspan="5" style="text-align:center;">No leaderboard data available yet.</td></tr>';
      return;
    }

    tbody.innerHTML = json.data.map((user, idx) => {
      const username = user.attributes.username;
      const discussions = user.attributes.discussionCount || 0;
      const comments = user.attributes.commentCount || 0;
      const points = (discussions * 5) + (comments * 2);
      const rank = idx + 1;

      return `
        <tr>
          <td><span class="rank-badge ${rank === 1 ? 'rank-1' : ''}">#${rank}</span></td>
          <td><strong>${username}</strong></td>
          <td>${discussions}</td>
          <td>${comments}</td>
          <td><strong class="highlight-gold">${points} pts</strong></td>
        </tr>
      `;
    }).join('');
  } catch (err) {
    tbody.innerHTML = '<tr><td colspan="5" style="text-align:center; color:#ef4444;">Error fetching scoreboard.</td></tr>';
  }
}
