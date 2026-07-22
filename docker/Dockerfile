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

# Copy everything built from Stage 1 into the runtime container
COPY --from=builder /app /var/www/html

RUN mkdir -p /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html

COPY custom-php.ini /usr/local/etc/php/conf.d/custom-php.ini
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
