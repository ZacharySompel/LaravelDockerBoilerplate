#!/usr/bin/env bash
set -e

APP_DIR="/var/www/html"
export COMPOSER_CACHE_DIR="/tmp/composer"

echo "🌟 DEV entrypoint starting (AUTO_INSTALL=${AUTO_INSTALL})"

# If there's no Laravel app yet AND auto-install is ON, scaffold it.
if [ ! -f "$APP_DIR/public/index.php" ] && [ "${AUTO_INSTALL}" = "1" ]; then
  echo "🔧 No app found in ${APP_DIR}. Bootstrapping Laravel..."
  cd "$APP_DIR"

  if [ -n "${LARAVEL_VERSION}" ]; then
    composer create-project laravel/laravel:"${LARAVEL_VERSION}" . --no-interaction
  else
    composer create-project laravel/laravel . --no-interaction
  fi

  # Create .env if missing and point DB to the 'mysql' service
  [ -f ".env" ] || cp .env.example .env || true

  sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=mysql/' .env || true
  sed -i 's/^DB_HOST=.*/DB_HOST=mysql/' .env || true
  sed -i 's/^DB_PORT=.*/DB_PORT=3306/' .env || true
  sed -i 's/^DB_DATABASE=.*/DB_DATABASE='"${MYSQL_DATABASE:-appdb}"'/' .env || true
  sed -i 's/^DB_USERNAME=.*/DB_USERNAME='"${MYSQL_USER:-appuser}"'/' .env || true
  sed -i 's/^DB_PASSWORD=.*/DB_PASSWORD='"${MYSQL_PASSWORD:-apppass}"'/' .env || true
  sed -i 's/^APP_URL=.*/APP_URL=http:\/\/localhost:'"${DEV_HTTP_PORT:-8080}"'/' .env || true

  php artisan key:generate --force || true

  # Permissions so storage/ and cache/ work
  chown -R www-data:www-data "$APP_DIR"
  find storage bootstrap/cache -type d -exec chmod 775 {} \; || true
  find storage bootstrap/cache -type f -exec chmod 664 {} \; || true

  echo "✅ Laravel install complete."
fi

# Ensure proper ownership if repo already had code
chown -R www-data:www-data "$APP_DIR" || true

echo "▶️  Starting php-fpm (dev)..."
exec php-fpm
