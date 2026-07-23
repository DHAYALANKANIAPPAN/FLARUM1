#!/usr/bin/env bash
set -euo pipefail
cd /var/www/html

echo "[entrypoint] Waiting for database at ${DB_HOST}..."
until mysqladmin ping -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl --silent; do
  sleep 2
done
echo "[entrypoint] Database is reachable."

if [ ! -f config.php ]; then
  echo "[entrypoint] No config.php — running Flarum installer..."
  php flarum install --no-interaction \
    --baseUrl="${APP_URL}" \
    --databaseHost="${DB_HOST}" \
    --databaseName="${DB_NAME}" \
    --databaseUser="${DB_USER}" \
    --databasePassword="${DB_PASS}" \
    --adminUser="${FLARUM_ADMIN_USER:-admin}" \
    --adminPassword="${FLARUM_ADMIN_PASSWORD:-changeme}" \
    --adminEmail="${FLARUM_ADMIN_EMAIL:-admin@example.com}" \
    --title="${FLARUM_FORUM_TITLE:-Community Forum}"

  php flarum extension:enable fof-upload || true
  php flarum extension:enable fof-best-answer || true
  php flarum extension:enable huseyinfiliz-leaderboard || true
else
  echo "[entrypoint] Existing install — clearing cache."
  php flarum cache:clear || true
fi

exec "$@"
