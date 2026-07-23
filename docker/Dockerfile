FROM php:8.3-fpm-alpine

RUN apk add --no-cache \
    bash \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    oniguruma-dev \
    mysql-client \
    git \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo_mysql mysqli zip intl mbstring opcache

COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

RUN composer create-project flarum/flarum . --no-interaction --no-dev --prefer-dist \
    && composer require \
        fof/upload \
        fof/best-answer \
        huseyinfiliz/leaderboard \
        --no-interaction --no-update \
    && composer update --no-dev --no-interaction --optimize-autoloader

RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage public/assets

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
