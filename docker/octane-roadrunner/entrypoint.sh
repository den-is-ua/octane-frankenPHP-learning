#!/bin/sh
set -e

if [ -f /app/artisan ] && [ ! -d /app/vendor ]; then
  echo "Installing Composer dependencies..."
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

cd /app
if [ ! -f ./rr ] || ! ./rr version >/dev/null 2>&1; then
  echo "Installing / refreshing RoadRunner binary for this platform..."
  rm -f ./rr
  php artisan octane:install --server=roadrunner --no-interaction --force
fi

exec "$@"
