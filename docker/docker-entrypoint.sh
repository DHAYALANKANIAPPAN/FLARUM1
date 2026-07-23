#!/usr/bin/env bash
set -euo pipefail
cd /var/www/html

echo "[entrypoint] Waiting for database at ${DB_HOST}..."
until mysqladmin ping -h"${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" --skip-ssl --silent; do
  sleep 2
done
echo "[entrypoint] Database is reachable."

if [ ! -f config.php ]; then
  echo "[entrypoint] No config.php — generating automated configuration..."
  
  # Write out the Flarum config.php file programmatically using environment variables
  cat <<PHP > config.php
<?php
return [
    'database' => [
        'driver'    => 'mysql',
        'host'      => '${DB_HOST}',
        'database'  => '${DB_NAME}',
        'username'  => '${DB_USER}',
        'password'  => '${DB_PASS}',
        'charset'   => 'utf8mb4',
        'collation' => 'utf8mb4_unicode_ci',
        'prefix'    => 'flarum_',
        'port'      => '3306',
        'strict'    => true,
        'engine'    => 'InnoDB',
    ],
    'url'     => '${APP_URL}',
    'paths'   => [
        'api'   => 'api',
        'admin' => 'admin',
    ],
];
PHP

  echo "[entrypoint] Running database migrations and enabling extensions..."
  php flarum migrate || true
  
  php flarum extension:enable fof-upload || true
  php flarum extension:enable fof-best-answer || true
  php flarum extension:enable huseyinfiliz-leaderboard || true
else
  echo "[entrypoint] Existing install — clearing cache."
  php flarum cache:clear || true
fi

exec "$@"
