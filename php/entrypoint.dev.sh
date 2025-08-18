#!/usr/bin/env sh
set -eu

APP_DIR="/var/www/html"     # keep this in sync with WORKDIR & your volume mount
export COMPOSER_CACHE_DIR="/tmp/composer"

echo "🌟 DEV entrypoint starting (AUTO_INSTALL=${AUTO_INSTALL-0})"

# If AUTO_INSTALL is set to 1 and no app exists yet, scaffold Laravel
if [ ! -f "$APP_DIR/public/index.php" ] && [ "${AUTO_INSTALL-0}" = "1" ]; then
  echo "🔧 No app found in ${APP_DIR}. Bootstrapping Laravel..."
  cd "$APP_DIR"

  if [ -n "${LARAVEL_VERSION-}" ]; then
    composer create-project "laravel/laravel:${LARAVEL_VERSION}" . --no-interaction
  else
    composer create-project laravel/laravel . --no-interaction
  fi

  # Create .env if missing and set defaults pointing to docker mysql service
  if [ ! -f ".env" ]; then
    cp .env.example .env || true
  fi

  # Normalize line endings in case the host wrote CRLF
  sed -i 's/\r$//' .env || true

  # Safe in-place updates (patterns matched from beginning of line)
  sed -i "s/^DB_CONNECTION=.*/DB_CONNECTION=mysql/" .env || true
  sed -i "s/^DB_HOST=.*/DB_HOST=mysql/" .env || true
  sed -i "s/^DB_PORT=.*/DB_PORT=3306/" .env || true
  sed -i "s/^DB_DATABASE=.*/DB_DATABASE=${MYSQL_DATABASE:-appdb}/" .env || true
  sed -i "s/^DB_USERNAME=.*/DB_USERNAME=${MYSQL_USER:-appuser}/" .env || true
  sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=${MYSQL_PASSWORD:-apppass}/" .env || true
  sed -i "s#^APP_URL=.*#APP_URL=http://localhost:${DEV_HTTP_PORT:-8080}#" .env || true

  php artisan key:generate --force || true

  # Permissions so storage/ and cache/ work
  chown -R www-data:www-data "$APP_DIR" || true
  (cd "$APP_DIR" && find storage bootstrap/cache -type d -exec chmod 775 {} \; 2>/dev/null || true)
  (cd "$APP_DIR" && find storage bootstrap/cache -type f -exec chmod 664 {} \; 2>/dev/null || true)

  echo "✅ Laravel install complete."
fi

# Ensure proper ownership if repo already had code
chown -R www-data:www-data "$APP_DIR" || true

echo "▶️  Starting php-fpm (dev)..."
exec php-fpm
