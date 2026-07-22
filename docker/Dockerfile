# Stage 1: Build Flarum & extensions
FROM composer:2.6 AS builder
WORKDIR /app
RUN composer create-project flarum/flarum . --stability=beta
RUN composer require fof/upload fof/best-answer huseyinfiliz/leaderboard

# Stage 2: Runtime PHP-FPM
FROM php:8.3-fpm-alpine
WORKDIR /var/www/html

RUN apk add --no-cache \
    curl libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev icu-dev netcat-openbsd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip intl opcache

# Copy the entire Flarum build from Stage 1
COPY --from=builder /app /var/www/html

# Ensure required directories exist and permissions are correct
RUN mkdir -p /var/www/html/storage \
    && mkdir -p /var/www/html/public

COPY docker/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN chmod +x /usr/local/bin/docker-entrypoint \
    && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
