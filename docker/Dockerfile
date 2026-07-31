FROM php:8.3-fpm-alpine

# Install system dependencies required by Flarum and the extension installer
RUN apk add --no-cache \
    bash \
    git \
    unzip \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    icu-dev \
    oniguruma-dev \
    mariadb-client

# Download the robust PHP extension installer utility
ADD https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions /usr/local/bin/
RUN chmod +x /usr/local/bin/install-php-extensions

# Install all required PHP extensions safely using pre-compiled binaries/scripts
RUN install-php-extensions \
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
RUN composer create-project flarum/flarum . --stability=beta

# Copy entrypoint script and make it executable
COPY docker/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["php-fpm"]
