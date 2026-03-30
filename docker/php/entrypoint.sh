#!/bin/sh
set -e

if [ -f /app/artisan ] && [ ! -d /app/vendor ]; then
  echo "Installing Composer dependencies..."
  composer install --no-interaction --prefer-dist --optimize-autoloader
fi

exec "$@"
