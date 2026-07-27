document.addEventListener('click', function(event) {
    // Check if the clicked element is Flarum's admin "Save Changes" button
    if (event.target && event.target.matches('button.Button--primary') && event.target.textContent.includes('Save Changes')) {
        // Wait 1 second for the background API request to finish transmitting, then reload
        setTimeout(function() {
            location.reload();
        }, 1000);
    }
});
