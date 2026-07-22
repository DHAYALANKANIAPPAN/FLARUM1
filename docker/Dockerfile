# Stage 1: Build Flarum & extensions
FROM composer:2.6 AS builder
WORKDIR /app

RUN composer create-project flarum/flarum . --stability=beta

# Install Flarum plugins (upload, best-answer, leaderboard)
RUN composer require fof/upload fof/best-answer huseyinfiliz/leaderboard

# Stage 2: Runtime PHP-FPM
FROM php:8.3-fpm-alpine
WORKDIR /var/www/html

RUN apk add --no-cache \
    curl libpng-dev libjpeg-turbo-dev freetype-dev libzip-dev icu-dev netcat-openbsd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip intl opcache

COPY --from=builder /app /var/www/html

# Ensure required directories exist
RUN mkdir -p /var/www/html/assets \
    && mkdir -p /var/www/html/storage \
    && mkdir -p /var/www/html/frontend

# CRITICAL: Copy your actual local frontend folder (which contains index.html) into the container
COPY ./frontend /var/www/html/frontend

COPY docker/custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN chmod +x /usr/local/bin/docker-entrypoint \
    && chown -R www-data:www-data /var/www/html

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
