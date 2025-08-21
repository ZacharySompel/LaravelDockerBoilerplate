# Laravel + Directus (Dev)

This branch adds **Directus** to the Laravel Docker stack so you can run **Laravel (PHP)** and a **Directus headless CMS** side‑by‑side on one Docker network.

Stack:

* **Nginx** → serves Laravel (`public/`)
* **PHP-FPM** → runs Laravel
* **MySQL 8** → databases for Laravel **and** Directus
* **phpMyAdmin** → DB GUI
* **Directus** → headless CMS/API ([http://localhost:8055](http://localhost:8055) by default)

> No global PHP/Composer/MySQL/Node required on your machine.

---

## Prereqs

* Docker Desktop (Mac/Windows) or Docker Engine (Linux)

---

## Quick Start

```bash
# 1) Clone this branch into a folder
git clone https://github.com/ZacharySompel/LaravelDockerBoilerplate.git .
cd laravel-stack   # or your folder
git switch directus # loads up directus branch

# 2) Copy the default dev env
cp .env.dev .env

# 3) Start the stack (builds images on first run)
docker compose --env-file .env -f docker-compose.dev.yml up -d --build

# 4) Bootstrap Laravel (only first time)
cp .env.laravel app/.env
docker compose -f docker-compose.dev.yml exec php composer install
docker compose -f docker-compose.dev.yml exec php php artisan key:generate
docker compose -f docker-compose.dev.yml exec php php artisan migrate:fresh --seed

# 5) Open apps
# Laravel:   http://localhost:8080
# Statamic:  http://localhost:8080/cp
# Directus:  http://localhost:8055
# phpMyAdmin http://localhost:8081

# 6) Seed Laravel app env into the container (first install only)
#    If you already have app/.env, you can skip this.
[ -f app/.env ] || cp .env.laravel app/.env

# 7) Generate Laravel app key & run migrations (inside the php container)
docker compose -f docker-compose.dev.yml exec php php artisan key:generate --ansi
# Optional: set up a fresh DB for Laravel
# docker compose -f docker-compose.dev.yml exec php php artisan migrate:fresh --seed
```

Open:

* Laravel app → [http://localhost:8080](http://localhost:8080)  (or your `DEV_HTTP_PORT`)
* Directus → [http://localhost:8055](http://localhost:8055)
* phpMyAdmin → [http://localhost:8081](http://localhost:8081)

On the first Directus visit, sign in with `ADMIN_EMAIL` / `ADMIN_PASSWORD` from `.env.directus`.

---

## Environment Files

* **`.env`** → used by Docker Compose (project name, ports, DB root creds).
* **`.env.laravel`** → copied to `app/.env` for Laravel runtime configuration.
* **`.env.directus`** → used by the Directus container for its runtime config.

**Important:** Do **not** commit `.env*` files. Add these to `.gitignore`.

Example `.gitignore` additions:

```
.env
.env.dev
.env.laravel
.env.directus
app/.env
mysql-data/
directus-uploads/
directus-extensions/
```

---

## Directus Notes

* The SQL in `mysql/init/01-create-directus.sql` only runs the **first time** the MySQL volume is created. If you already have data, either:

  * Create DB & user manually via phpMyAdmin, **or**
  * Temporarily exec into MySQL and run the same SQL:

    ```bash
    docker compose exec mysql mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
      CREATE DATABASE IF NOT EXISTS directus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
      CREATE USER IF NOT EXISTS 'directus'@'%' IDENTIFIED BY 'directuspass';
      GRANT ALL PRIVILEGES ON directus.* TO 'directus'@'%';
      FLUSH PRIVILEGES;"
    ```

* If you change `.env.directus`, restart Directus:

  ```bash
  docker compose restart directus
  ```

* Default Directus uploads/extensions are persisted in named volumes:

  * `directus-uploads`
  * `directus-extensions`

---

## Common Troubleshooting

### Directus: `ER_ACCESS_DENIED_ERROR` for user 'directus'@

Cause: DB user/database missing or wrong password.
Fix:

1. Verify `.env.directus` matches your MySQL creds.
2. Ensure `directus` DB and user exist (see SQL above).
3. Restart Directus: `docker compose restart directus`.

### Laravel: "Could not open input file: artisan"

Cause: Composer deps not installed yet.
Fix:

```bash
docker compose -f docker-compose.dev.yml exec php sh -lc 'cd /var/www/html && composer install'
```

### 502 from Nginx

* Ensure `php` container is healthy and exposed on port 9000.
* Check `nginx/site.dev.conf` `fastcgi_pass php:9000;` matches the service name `php`.

---

## Ports & Variables (defaults)

* App (Nginx) → `${DEV_HTTP_PORT:-8080}`
* phpMyAdmin → `${PHPMYADMIN_PORT:-8081}`
* Directus → `${DIRECTUS_PORT:-8055}`

You can change these in `.env`.

---

## Optional: Make Your Own Repo

```bash
rm -rf .git
git init
git add .
git commit -m "Initial commit - Laravel + Directus stack"
# git remote add origin <your-ssh-or-https-url>
# git push -u origin main
```

---

## Production-ish Notes (very high level)

* Run Directus and Laravel behind a real reverse proxy (Nginx/Traefik) with TLS.
* Use managed DB (RDS/Aurora/Cloud SQL) or durable volumes.
* Configure backups for DB and `/directus/uploads`.
* Set strong random `KEY` and `SECRET` in `.env.directus`.
* Lock down phpMyAdmin to dev only (don’t expose it in prod).
