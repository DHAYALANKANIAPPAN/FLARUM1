FROM php:8.3-fpm

RUN apt-get update && apt-get install -y \
    unzip git curl \
    libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libwebp-dev \
    libicu-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j$(nproc) pdo_mysql mysqli gd zip exif intl opcache \
    && rm -rf /var/lib/apt/lists/*

COPY --from=composer:latest /usr/bin/composer /usr/local/bin/composer

WORKDIR /var/www/html

RUN composer create-project flarum/flarum . --stability=beta --no-interaction

RUN composer require flarum/tags flarum/mentions flarum/sticky flarum/lock \
    huseyinfiliz/leaderboard fof/upload fof/best-answer --no-interaction

RUN mkdir -p storage public/assets \
    && chown -R www-data:www-data /var/www/html

COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
