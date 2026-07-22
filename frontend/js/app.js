const API_BASE = '/api';
let uploadedFileUrl = '';

document.addEventListener('DOMContentLoaded', () => {
  fetchDiscussions();
  setupModalHandlers();
  setupFormSubmit();
  setupFileUpload();
});

async function fetchDiscussions() {
  const container = document.getElementById('discussionList');
  try {
    const res = await fetch(`${API_BASE}/discussions?include=user`);
    const json = await res.json();
    
    if (!json.data || json.data.length === 0) {
      container.innerHTML = '<div class="loading-spinner">No discussions found. Start one!</div>';
      return;
    }

    container.innerHTML = json.data.map(disc => {
      const title = disc.attributes.title;
      const commentCount = disc.attributes.commentCount || 1;
      const user = json.included?.find(i => i.type === 'users' && i.id === disc.relationships?.user?.data?.id);
      const username = user ? user.attributes.username : 'Anonymous';
      const initial = username.charAt(0).toUpperCase();

      return `
        <div class="DiscussionListItem">
          <div class="DiscussionListItem-author">
            <div class="Avatar">${initial}</div>
            <div>
              <a href="#" class="DiscussionListItem-title">${escapeHTML(title)}</a>
              <div class="DiscussionListItem-info">Started by <strong>${username}</strong></div>
            </div>
          </div>
          <div class="DiscussionListItem-stats">
            <span><i class="fa-regular fa-comment"></i> ${commentCount}</span>
          </div>
        </div>
      `;
    }).join('');
  } catch (err) {
    container.innerHTML = '<div class="loading-spinner" style="color:#ef4444;">Failed to load discussions from Flarum API.</div>';
  }
}

function setupFileUpload() {
  const fileInput = document.getElementById('imageUpload');
  const status = document.getElementById('uploadStatus');

  fileInput.addEventListener('change', async () => {
    if (!fileInput.files[0]) return;
    status.innerText = 'Uploading image...';

    const formData = new FormData();
    formData.append('files[]', fileInput.files[0]);

    try {
      const res = await fetch(`${API_BASE}/fof/upload`, {
        method: 'POST',
        body: formData
      });
      const data = await res.json();
      if (data.data && data.data[0]) {
        uploadedFileUrl = data.data[0].attributes.url;
        status.innerText = 'Image attached successfully!';
        status.style.color = '#22c55e';
      }
    } catch (e) {
      status.innerText = 'Image upload failed.';
      status.style.color = '#ef4444';
    }
  });
}

function setupFormSubmit() {
  const form = document.getElementById('createDiscussionForm');
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    const title = document.getElementById('discussionTitle').value;
    let content = document.getElementById('discussionContent').value;

    if (uploadedFileUrl) {
      content += `\n\n![Uploaded Image](${uploadedFileUrl})`;
    }

    try {
      const res = await fetch(`${API_BASE}/discussions`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          data: {
            attributes: { title, content }
          }
        })
      });

      if (res.ok) {
        document.getElementById('modalBackdrop').style.display = 'none';
        form.reset();
        uploadedFileUrl = '';
        document.getElementById('uploadStatus').innerText = '';
        fetchDiscussions();
      }
    } catch (err) {
      alert('Error creating discussion');
    }
  });
}

function setupModalHandlers() {
  const backdrop = document.getElementById('modalBackdrop');
  document.getElementById('openModalBtn').onclick = () => backdrop.style.display = 'flex';
  document.getElementById('closeModalBtn').onclick = () => backdrop.style.display = 'none';
}

function escapeHTML(str) {
  return str.replace(/[&<>'"]/g, tag => ({'&': '&amp;', '<': '&lt;', '>': '&gt;', "'": '&#39;', '"': '&quot;'}[tag]));
}
