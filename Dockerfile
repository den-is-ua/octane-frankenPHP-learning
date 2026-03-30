# Laravel Octane (FrankenPHP) — https://frankenphp.dev/docs/laravel/#laravel-octane
FROM dunglas/frankenphp:1-php8.4

WORKDIR /app

# Octane workers + typical Laravel DB/queue extensions
RUN install-php-extensions pcntl pdo_mysql redis zip

COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

ENV COMPOSER_ALLOW_SUPERUSER=1

COPY docker/php/entrypoint.sh /usr/local/bin/app-entrypoint.sh
RUN chmod +x /usr/local/bin/app-entrypoint.sh

# Replace FrankenPHP’s default entrypoint (frankenphp run); Octane drives FrankenPHP.
ENTRYPOINT ["app-entrypoint.sh"]
CMD ["php", "artisan", "octane:frankenphp", "--host=0.0.0.0", "--port=8000"]
