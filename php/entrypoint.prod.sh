#!/usr/bin/env bash
set -e

APP_DIR="/var/www/html"
export COMPOSER_CACHE_DIR="/tmp/composer"

echo "🚀 PROD entrypoint (AUTO_INSTALL=${AUTO_INSTALL})"

# Allow one-time bootstrap on a fresh server if AUTO_INSTALL=1
if [ ! -f "$APP_DIR/public/index.php" ] && [ "${AUTO_INSTALL}" = "1" ]; then
  echo "🔧 First-time bootstrap: installing Laravel..."
  cd "$APP_DIR"

  if [ -n "${LARAVEL_VERSION}" ]; then
    composer create-project laravel/laravel:"${LARAVEL_VERSION}" . --no-interaction --no-dev
  else
    composer create-project laravel/laravel . --no-interaction --no-dev
  fi

  [ -f ".env" ] || cp .env.example .env || true

  sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env || true
  sed -i 's/^DB_HOST=.*/DB_HOST=mysql/' .env || true
  sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env || true
  sed -i 's/^DB_DATABASE=.*/DB_DATABASE='"${MYSQL_DATABASE:-appdb}"'/' .env || true
  sed -i 's/^DB_USERNAME=.*/DB_USERNAME='"${MYSQL_USER:-appuser}"'/' .env || true
  sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD='"${MYSQL_PASSWORD:-apppass}"'/' .env || true

  php artisan key:generate --force || true

  chown -R www-data:www-data "$APP_DIR"
  find storage bootstrap/cache -type d -exec chmod 775 {} \; || true
  find storage bootstrap/cache -type f -exec chmod 664 {} \; || true

  echo "✅ Laravel install complete (prod)."
fi

echo "▶️  Starting php-fpm (prod)..."
exec php-fpm
