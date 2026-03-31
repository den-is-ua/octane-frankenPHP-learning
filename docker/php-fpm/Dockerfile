FROM php:8.4-fpm-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && curl -sSLf -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions pdo_mysql redis zip opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Allow nginx (separate container) to reach FPM on the Docker network
RUN sed -i 's/listen = 127.0.0.1:9000/listen = 9000/g' /usr/local/etc/php-fpm.d/www.conf

WORKDIR /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1
