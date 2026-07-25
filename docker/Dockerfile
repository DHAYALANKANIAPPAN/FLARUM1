FROM php:8.2-fpm-alpine

# Install system dependencies and PHP extensions required by Flarum
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    mariadb-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        gd \
        pdo_mysql \
        intl \
        mbstring \
        exif \
        pcntl \
        bcmath

# Install Composer globally
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install Flarum via Composer if not already present, or copy codebase
# (If your project pulls dependencies via composer, this handles it)
RUN composer create-project flarum/flarum . --stability=beta

# Copy entrypoint script and make it executable
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
