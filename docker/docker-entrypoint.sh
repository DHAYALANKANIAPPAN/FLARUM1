#!/bin/bash
set -e

echo "[entrypoint] Starting Flarum container setup..."

DATA_DIR="/data"
APP_DIR="/var/www/html"

mkdir -p "$DATA_DIR/storage" "$DATA_DIR/assets"

echo "[entrypoint] Waiting for database at $DB_HOST..."
until php -r "new PDO('mysql:host=$DB_HOST;dbname=$DB_DATABASE', '$DB_USERNAME', '$DB_PASSWORD');" 2>/dev/null; do
  echo "[entrypoint] Database not ready yet, retrying in 2s..."
  sleep 2
done
echo "[entrypoint] Database is reachable."

if [ -d "$APP_DIR/storage" ] && [ ! -L "$APP_DIR/storage" ]; then rm -rf "$APP_DIR/storage"; fi
ln -sfn "$DATA_DIR/storage" "$APP_DIR/storage"

if [ -d "$APP_DIR/public/assets" ] && [ ! -L "$APP_DIR/public/assets" ]; then rm -rf "$APP_DIR/public/assets"; fi
ln -sfn "$DATA_DIR/assets" "$APP_DIR/public/assets"

if [ -f "$DATA_DIR/config.php" ]; then
  echo "[entrypoint] Existing config.php found — leaving it untouched."
else
  echo "[entrypoint] Generating config.php from environment variables."
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

echo "[entrypoint] Running migrations (safe no-op if DB already has Flarum tables)..."
su -s /bin/bash www-data -c "php $APP_DIR/flarum migrate" || true

# Configure mail via direct settings-table writes (Flarum core has no
# "config:set" CLI command — this is the reliable, confirmed-working method).
# Safe to re-run: only updates these specific setting rows, never touches
# user/discussion/post data.
if [ -n "$MAIL_HOST" ]; then
  echo "[entrypoint] Configuring SMTP mail settings..."
  php -r "
    \$pdo = new PDO('mysql:host=$DB_HOST;dbname=$DB_DATABASE', '$DB_USERNAME', '$DB_PASSWORD');
    \$settings = [
      'mail_driver' => 'smtp',
      'mail_host' => '$MAIL_HOST',
      'mail_port' => '$MAIL_PORT',
      'mail_username' => '$MAIL_USERNAME',
      'mail_password' => '$MAIL_PASSWORD',
      'mail_from' => '$MAIL_FROM',
      'mail_encryption' => 'tls',
    ];
    foreach (\$settings as \$key => \$value) {
      \$stmt = \$pdo->prepare('INSERT INTO settings (\`key\`, value) VALUES (?, ?) ON DUPLICATE KEY UPDATE value = VALUES(value)');
      \$stmt->execute([\$key, \$value]);
    }
  " || echo "[entrypoint] Mail settings write skipped (DB may not be migrated yet on first run)."
fi

echo "[entrypoint] Publishing assets..."
su -s /bin/bash www-data -c "php $APP_DIR/flarum assets:publish" || true

echo "[entrypoint] Clearing cache..."
su -s /bin/bash www-data -c "php $APP_DIR/flarum cache:clear" || true

echo "[entrypoint] Setup complete. Starting application."
exec "$@"
