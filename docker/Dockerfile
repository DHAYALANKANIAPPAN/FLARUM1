FROM php:8.3-fpm-alpine

# Install Nginx, Supervisor (to run both Nginx and PHP-FPM together), and dependencies
RUN apk add --no-cache \
    nginx \
    supervisor \
    curl \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    icu-dev \
    netcat-openbsd \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd pdo_mysql zip intl opcache

# Install Composer
COPY --from=composer:2.6 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Install Flarum
RUN composer create-project flarum/flarum . --stability=beta \
    && composer require fof/upload fof/best-answer huseyinfiliz/leaderboard

# Copy Nginx configuration inside the container
COPY docker/nginx.conf /etc/nginx/http.d/default.conf

# Configure Supervisor to run Nginx and PHP-FPM concurrently
RUN mkdir -p /etc/supervisor.d/
COPY <<EOF /etc/supervisor.d/supervisord.ini
[supervisord]
nodaemon=true

[program:php-fpm]
command=php-fpm
autostart=true
autorestart=true

[program:nginx]
command=nginx -g "daemon off;"
autostart=true
autorestart=true
EOF

RUN mkdir -p /var/www/html/storage \
    && chown -R www-data:www-data /var/www/html

EXPOSE 80

CMD ["supervisord", "-c", "/etc/supervisor.d/supervisord.ini"]
