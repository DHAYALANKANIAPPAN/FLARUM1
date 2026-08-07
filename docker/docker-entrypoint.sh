#!/usr/bin/env bash
set -e

cd /var/www/html

echo "======================================="
echo " Starting Flarum Container"
echo "======================================="

echo "Waiting for MariaDB..."

until mysqladmin ping \
    -h"${DB_HOST}" \
    -u"${DB_USER}" \
    -p"${DB_PASS}" \
    --silent
do
    sleep 2
done

echo "Database Ready."

##########################################################
# Generate config only once
##########################################################

if [ ! -f config.php ]; then

cat > config.php <<EOF
<?php

return [

    'debug' => false,

    'database' => [

        'driver' => 'mysql',

        'host' => '${DB_HOST}',

        'port' => 3306,

        'database' => '${DB_NAME}',

        'username' => '${DB_USER}',

        'password' => '${DB_PASS}',

        'charset' => 'utf8mb4',

        'collation' => 'utf8mb4_unicode_ci',

        'prefix' => '',

        'strict' => false,

        'engine' => 'InnoDB',

    ],

    'url' => '${APP_URL}',

    'paths' => [

        'api' => 'api',

        'admin' => 'admin',

    ],

];
EOF

fi

##########################################################
# Storage
##########################################################

mkdir -p storage

mkdir -p storage/cache

mkdir -p storage/logs

mkdir -p storage/sessions

mkdir -p storage/views

mkdir -p public/assets

mkdir -p public/assets/uploads

##########################################################
# Publish assets every startup
##########################################################

php flarum assets:publish || true

##########################################################
# Cache
##########################################################

php flarum cache:clear || true

##########################################################
# Permissions
##########################################################

chown -R www-data:www-data storage

chown -R www-data:www-data public/assets

chmod -R 775 storage

chmod -R 775 public/assets

echo "Container Ready."

exec "$@"
