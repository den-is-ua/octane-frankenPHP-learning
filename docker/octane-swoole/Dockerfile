FROM php:8.4-cli-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && curl -sSLf -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    && chmod +x /usr/local/bin/install-php-extensions \
    && install-php-extensions swoole pdo_mysql redis zip pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY docker/php/entrypoint.sh /usr/local/bin/app-entrypoint.sh
RUN chmod +x /usr/local/bin/app-entrypoint.sh

ENTRYPOINT ["app-entrypoint.sh"]
CMD ["php", "artisan", "octane:start", "--server=swoole", "--host=0.0.0.0", "--port=8000"]
