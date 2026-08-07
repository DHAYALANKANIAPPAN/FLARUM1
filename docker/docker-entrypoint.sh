#!/bin/bash
set -e

echo "[entrypoint] Starting Flarum container setup..."

DATA_DIR="/data"
APP_DIR="/var/www/html"

mkdir -p "$DATA_DIR/storage" "$DATA_DIR/assets"

# ---- Wait for MariaDB to actually accept connections ----
echo "[entrypoint] Waiting for database at $DB_HOST..."
until php -r "new PDO('mysql:host=$DB_HOST;dbname=$DB_DATABASE', '$DB_USERNAME', '$DB_PASSWORD');" 2>/dev/null; do
  echo "[entrypoint] Database not ready yet, retrying in 2s..."
  sleep 2
done
echo "[entrypoint] Database is reachable."

# ---- Link persistent storage (uploads, cache, logs) ----
if [ -d "$APP_DIR/storage" ] && [ ! -L "$APP_DIR/storage" ]; then
  rm -rf "$APP_DIR/storage"
fi
ln -sfn "$DATA_DIR/storage" "$APP_DIR/storage"

# ---- Link persistent compiled assets (shared read-only with nginx) ----
if [ -d "$APP_DIR/public/assets" ] && [ ! -L "$APP_DIR/public/assets" ]; then
  rm -rf "$APP_DIR/public/assets"
fi
ln -sfn "$DATA_DIR/assets" "$APP_DIR/public/assets"

# ---- config.php: NEVER overwrite if it already exists ----
if [ -f "$DATA_DIR/config.php" ]; then
  echo "[entrypoint] Existing config.php found in persistent volume — leaving it untouched."
else
  echo "[entrypoint] No config.php found — generating one from environment variables."
  cat > "$DATA_DIR/config.php" <<PHP
<?php return array (
  'debug' => false,
  'database' =>
  array (
    'driver' => 'mysql',
    'host' => '${DB_HOST}',
    'port' => 3306,
    'database' => '${DB_DATABASE}',
    'username' => '${DB_USERNAME}',
    'password' => '${DB_PASSWORD}',
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
    'engine' => 'InnoDB',
    'prefix_indexes' => true,
  ),
  'url' => '${APP_URL}',
  'paths' =>
  array (
    'api' => 'api',
    'admin' => 'admin',
  ),
);
PHP
fi
ln -sfn "$DATA_DIR/config.php" "$APP_DIR/config.php"

chown -R www-data:www-data "$DATA_DIR" "$APP_DIR/storage" "$APP_DIR/public/assets" "$APP_DIR/config.php" 2>/dev/null || true

# ---- Migrate only if the database has no Flarum tables yet; otherwise this
#      is a safe no-op and will NOT touch or destroy existing data ----
echo "[entrypoint] Running migrations (safe no-op if already up to date)..."
su -s /bin/bash www-data -c "php $APP_DIR/flarum migrate" || true

echo "[entrypoint] Publishing assets..."
su -s /bin/bash www-data -c "php $APP_DIR/flarum assets:publish" || true

echo "[entrypoint] Clearing cache..."
su -s /bin/bash www-data -c "php $APP_DIR/flarum cache:clear" || true

echo "[entrypoint] Setup complete. Starting php-fpm."
exec "$@"
