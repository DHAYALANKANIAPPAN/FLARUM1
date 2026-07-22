#!/bin/sh
set -e

# If Flarum isn't installed yet in the shared volume/directory, install it via Composer
if [ ! -f /var/www/html/public/index.php ]; then
    echo "Flarum not found. Installing via Composer..."
    cd /var/www/html
    composer create-project flarum/flarum . --stability=beta --no-interaction
    composer require fof/upload fof/best-answer huseyinfiliz/leaderboard --no-interaction
fi

# Ensure correct permissions for web server
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html/storage /var/www/html/public

# Execute the main command (Supervisord)
exec "$@"
