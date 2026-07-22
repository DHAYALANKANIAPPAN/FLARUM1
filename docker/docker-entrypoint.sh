#!/bin/sh
set -e

echo "Waiting for MariaDB connection..."
until nc -z -v -w30 db 3306; do
  sleep 2
done

php flarum cache:clear || true
chown -R www-data:www-data /var/www/html/storage /var/www/html/assets

exec "$@"
