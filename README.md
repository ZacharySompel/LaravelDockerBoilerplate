# Laravel Docker Stack (Dev + Prod‑like)

This repo gives you a **ready‑to‑run Laravel environment** using Docker. It’s designed for **local development** and can be adapted for production‑like setups.

## What you get

* **Nginx** – serves the app
* **PHP‑FPM (PHP 8.3 Alpine)** – runs Laravel
* **MySQL 8** – database
* **phpMyAdmin** – web GUI for the DB

> No global PHP/Composer/MySQL needed on your machine.

---

## Prerequisites

* **Docker Desktop** (Windows/Mac) or **Docker Engine** (Linux)

---

## TL;DR – Getting Started (DEV)

```bash
# 1) Clone the repo
git clone https://github.com/ZacharySompel/LaravelDockerBoilerplate.git laravel-stack
cd laravel-stack

# 2) Copy the default dev env (used by Docker Compose)
cp .env.dev .env

# 3) Start the stack (builds images on first run)
docker compose --env-file .env -f docker-compose.dev.yml up -d --build

# 4) First run: ensure the app exists
# If ./app is empty, the container auto‑scaffolds Laravel (AUTO_INSTALL=1).
# If you prefer manual install or auto‑scaffold didn’t run:
docker compose -f docker-compose.dev.yml exec php sh -lc '
  cd /var/www/html &&
  [ -f artisan ] || composer create-project laravel/laravel . --no-interaction &&
  composer install --no-interaction --prefer-dist &&
  php artisan key:generate --ansi
'

# 5) Clear caches (good hygiene)
docker compose -f docker-compose.dev.yml exec php php artisan config:clear
docker compose -f docker-compose.dev.yml exec php php artisan cache:clear
docker compose -f docker-compose.dev.yml exec php php artisan route:clear
docker compose -f docker-compose.dev.yml exec php php artisan view:clear

# 6) Open the app + DB admin
# App:        http://localhost:8080
# phpMyAdmin: http://localhost:8081

# 7) (Optional) start a fresh git history
rm -rf .git && git init && git add . && git commit -m "Initial commit - Laravel Docker Stack"
```

**Windows PowerShell equivalents**

```powershell
Copy-Item .env.dev .env
# If you want to pre-seed Laravel’s .env on first run:
Copy-Item .env.laravel .\app\.env
```

---

## Notes & Troubleshooting (Windows/macOS/Linux)

### Cross‑platform entrypoint (no Bash required)

* The PHP image is **Alpine** and ships **/bin/sh**, not bash. The dev image uses a POSIX **sh** entrypoint so it works everywhere.

### Common errors & quick fixes

**1) `.env: can't execute 'bash'`**

* **Cause:** a script tries to run `bash` on Alpine, or CRLF broke the interpreter line.
* **Fix:** the dev Dockerfile runs the entrypoint with `sh` and strips CRLF during build. If you kept a bash shebang, either install bash (`apk add --no-cache bash`) or switch to `sh`.

**2) `Could not open input file: artisan`**

* **Cause:** you’re not in the directory that contains `artisan`, or Laravel wasn’t installed.
* **Fix:**

  ```bash
  docker compose -f docker-compose.dev.yml exec php sh -lc 'cd /var/www/html && php artisan --version'
  ```

  If missing, install into the **same** path mounted by Compose:

  ```bash
  docker compose -f docker-compose.dev.yml exec php sh -lc '
    cd /var/www/html &&
    composer create-project laravel/laravel . --no-interaction &&
    php artisan key:generate --ansi
  '
  ```

**3) `failed opening required '/var/www/html/vendor/autoload.php'`**

* **Cause:** `vendor/` doesn’t exist (Composer never ran in `/var/www/html`) or path mismatch.
* **Fix:**

  ```bash
  docker compose -f docker-compose.dev.yml exec php sh -lc '
    cd /var/www/html && composer install --no-interaction --prefer-dist
  '
  ```

**4) Infinite “waiting for .env / missing env” loop**

* **Cause:** wrong mount path or CRLF broke the entrypoint.
* **Fix:** ensure **everywhere** uses `/var/www/html` (Dockerfile `WORKDIR`, entrypoint `APP_DIR`, Compose volume/`working_dir`). Normalize line endings.

**5) “It looks like vendor isn’t mounted”**

* This stack **does not** overlay‑mount `vendor/` by default. If you want faster Windows I/O, you may opt‑in to a named volume:

  ```yaml
  services:
    php:
      volumes:
        - ./app:/var/www/html
        - vendor:/var/www/html/vendor
  volumes:
    vendor:
  ```

  Then populate it **inside** the container:

  ```bash
  docker compose -f docker-compose.dev.yml exec php sh -lc 'cd /var/www/html && composer install'
  ```

### Verify paths (quick diagnostics)

```bash
docker compose -f docker-compose.dev.yml logs php --tail=200

docker compose -f docker-compose.dev.yml exec php sh -lc 'pwd; ls -la /var/www /var/www/html'

docker compose -f docker-compose.dev.yml exec php sh -lc 'test -f /var/www/html/composer.json && echo has-composer.json || echo no-composer.json'
```

---

## Dev PHP Dockerfile (cross‑platform)

The dev Dockerfile is already **cross‑platform** (uses `sh`) and strips CRLF on the entrypoint during build:

```dockerfile
# Dev image: fast iteration, optional Xdebug
FROM php:8.3-fpm-alpine

# OS packages for common Laravel features (GD, ZIP, INTL, etc.)
RUN apk add --no-cache \
    git curl unzip icu-dev oniguruma-dev libzip-dev \
    libpng-dev libjpeg-turbo-dev libwebp-dev libxml2-dev

# PHP extensions for Laravel
RUN docker-php-ext-configure gd --with-jpeg --with-webp \
 && docker-php-ext-install -j"$(nproc)" pdo pdo_mysql mbstring zip intl gd xml opcache

# Optional Xdebug (disabled by default)
# RUN pecl install xdebug && docker-php-ext-enable xdebug

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Local PHP overrides
COPY conf.d/local.ini /usr/local/etc/php/conf.d/zz-local.ini

# Entrypoint: POSIX sh + strip CRLF
COPY entrypoint.dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
 && sed -i 's/\r$//' /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/bin/env", "sh", "/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
```

> If you keep a Bash‑specific entrypoint, add `apk add --no-cache bash` and change the entrypoint to `bash`. Using `sh` is simpler and avoids platform issues.

---

## Planned variants

* `main` – base Laravel stack (current branch)
* `statamic` – Laravel + \[Statam
