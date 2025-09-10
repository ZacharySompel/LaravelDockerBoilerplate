# Laravel + Directus + Meilisearch (Dev)

This branch adds **Directus** to the Laravel Docker stack and wires in **Meilisearch** for site search. You can run **Laravel (PHP)**, **Directus (headless CMS)**, **Meilisearch**, **Redis**, and **MySQL** on one Docker network.

## Stack

* **Nginx** → serves Laravel (`public/`)
* **PHP-FPM** → runs Laravel
* **MySQL 8** → databases for Laravel **and** Directus
* **phpMyAdmin** → DB GUI
* **Directus** → headless CMS/API (default: [http://localhost:8055](http://localhost:8055))
* **Meilisearch** → lightning-fast search engine (default: [http://localhost:7700](http://localhost:7700))
* **Redis** → queues, cache, session (dev convenience)

> No global PHP/Composer/MySQL/Node required on your machine.

---

## Prereqs

* Docker Desktop (Mac/Windows) or Docker Engine (Linux)

---

## Quick Start

```bash
# 1) Clone this branch
git clone https://github.com/ZacharySompel/LaravelDockerBoilerplate.git .
cd laravel-stack   # or your folder
git switch directus-meili

# 2) Copy the default dev env
cp .env.dev .env

# 3) Start the stack (builds images on first run)
docker compose --env-file .env -f docker-compose.dev.yml up -d --build

# 4) Bootstrap Laravel (first time)
cp .env.laravel app/.env
docker compose -f docker-compose.dev.yml exec php composer install
docker compose -f docker-compose.dev.yml exec php php artisan key:generate

# 5) Run migrations + seed (roles, permissions, default admin, etc.)
docker compose -f docker-compose.dev.yml exec php php artisan migrate --force
docker compose -f docker-compose.dev.yml exec php php artisan db:seed

# 6) Open apps
# Laravel:    http://localhost:8080
# Directus:   http://localhost:8055
# phpMyAdmin: http://localhost:8081
# Meilisearch:http://localhost:7700
```

On first Directus visit, sign in with `ADMIN_EMAIL` / `ADMIN_PASSWORD` from `.env.directus`.

---

## Environments

* **`.env`** → used by Docker Compose (project name, ports, DB root creds, Redis, Meili, etc.)
* **`.env.laravel`** → copied to `app/.env` (Laravel runtime: DB, cache/drivers, Scout, Sanctum)
* **`.env.directus`** → used by Directus container

**Do not commit** `.env*` files. Add these to `.gitignore`.

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
meili-data/
redis-data/
```

---

## Laravel configuration (important)

### Sanctum

Add the trait (already done in this branch):

```php
// app/Models/User.php
use Laravel\Sanctum\HasApiTokens;
use Spatie\Permission\Traits\HasRoles;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable, HasRoles;
}
```

### Spatie Roles/Permissions + default admin

The seeder creates:

* Permissions: `posts.create`, `posts.view`, `posts.update`, `posts.delete`
* Roles: `admin`, `editor`, `viewer`
* Default admin user (email/password configurable; see below)

Env overrides (optional) in `app/.env`:

```
ADMIN_SEED_EMAIL=admin@example.com
ADMIN_SEED_NAME="Default Admin"
ADMIN_SEED_PASSWORD=password123
```

### Redis (cache / sessions / queues)

`app/.env`:

```
CACHE_DRIVER=redis
SESSION_DRIVER=redis
QUEUE_CONNECTION=redis

REDIS_CLIENT=predis
REDIS_HOST=redis
REDIS_PORT=6379
```

### Scout + Meilisearch

`app/.env`:

```
SCOUT_DRIVER=meilisearch
MEILISEARCH_HOST=http://meilisearch:7700
MEILISEARCH_KEY=${MEILI_MASTER_KEY}
```

To index a model:

```php
use Laravel\Scout\Searchable;
class Post extends Model { use Searchable; }
```

Then:

```bash
docker compose -f docker-compose.dev.yml exec php php artisan scout:import "App\Models\Post"
```

---

## Directus Notes

* The SQL in `mysql/init/01-create-directus.sql` runs **only on first** MySQL volume creation.
* If you already have data, create the DB/user via phpMyAdmin or run SQL manually:

  ```bash
  docker compose exec mysql mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "
    CREATE DATABASE IF NOT EXISTS directus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
    CREATE USER IF NOT EXISTS 'directus'@'%' IDENTIFIED BY 'directuspass';
    GRANT ALL PRIVILEGES ON directus.* TO 'directus'@'%';
    FLUSH PRIVILEGES;"
  ```
* Restart Directus after `.env.directus` changes:

  ```bash
  docker compose restart directus
  ```

Uploads/extensions persist in named volumes:

* `directus-uploads`
* `directus-extensions`

---

## Ports & Variables (defaults)

* App (Nginx) → `${DEV_HTTP_PORT:-8080}`
* phpMyAdmin → `${PHPMYADMIN_PORT:-8081}`
* Directus → `${DIRECTUS_PORT:-8055}`
* Meilisearch → `${MEILI_PORT:-7700}`
* Redis → `${REDIS_PORT:-6379}`

Change in `.env` as needed.

---

## Common Troubleshooting

### 502 from Nginx

* Ensure `php` container is healthy & `fastcgi_pass php:9000;` matches service name.

### Laravel "Could not open input file: artisan"

* Composer deps not installed:

  ```bash
  docker compose -f docker-compose.dev.yml exec php sh -lc 'cd /var/www/html && composer install'
  ```

### Directus `ER_ACCESS_DENIED_ERROR`

* Check `.env.directus` creds and that DB/user exist (see SQL above), then:

  ```bash
  docker compose restart directus
  ```

### Scout indexing not working

* Confirm model uses `Searchable`
* Check `MEILISEARCH_HOST` resolves inside containers (use `meilisearch:7700`, not `localhost`)

---

## Production-ish Notes (very high level)

* Run behind a real reverse proxy (TLS, HTTP/2, compression).
* Move DB to managed RDS / Cloud SQL or durable volumes with backups.
* Back up `/directus/uploads` and DB.
* Use strong `KEY`/`SECRET` in `.env.directus`.
* Don’t expose phpMyAdmin publicly.

````

---

# COMPOSER.md

```md
# Composer Packages (directus-meili branch)

These are the packages currently required by the project and why we use them.

## Runtime

- `laravel/framework:^12.0` — Core framework
- `laravel/sanctum:^4.0` — Token auth for SPA/API endpoints
- `spatie/laravel-permission:^6.21` — Roles & permissions
- `spatie/laravel-activitylog:^4.10` — Audit log (“who did what”)
- `spatie/laravel-sitemap:^7.3` — Generate `sitemap.xml`
- `laravel/scout:^10.19` — Full-text search abstraction
- `meilisearch/meilisearch-php:^1.16` — Scout’s Meilisearch client
- `http-interop/http-factory-guzzle:^1.2` — PSR factories for the Meili client
- `doctrine/dbal:^4.3` — Safe column/enum renames in migrations
- `predis/predis:^3.2` — Redis client (queues/cache/session) in dev

## Dev / DX

- `barryvdh/laravel-debugbar:^3.16` — Debug info in dev
- `barryvdh/laravel-ide-helper:^3.6` — Better IDE autocompletion
- `phpunit/phpunit:^11.5.3` — Tests (kept in sync with Laravel 12)
- `nunomaduro/collision:^8.6` — Pretty CLI errors
- `fakerphp/faker`, `mockery/mockery`, `laravel/pint`, `laravel/sail`, `laravel/pail`

> We intentionally **skipped Pest** here because of version constraints with `phpunit` and `collision`. If you want Pest later, use:
>
> ```bash
> composer require --dev pestphp/pest:^3.8.4 pestphp/pest-plugin-laravel --with-all-dependencies phpunit/phpunit:^11.5.33
> php artisan pest:install
> ```

## Post-install reminders

- **Sanctum**: add `HasApiTokens` trait to `User`.
- **Spatie Permission**: add `HasRoles` trait to `User`.
- **Scout + Meilisearch**: configure `SCOUT_DRIVER` and `MEILISEARCH_HOST`.
- **Redis**: set `CACHE_DRIVER=redis`, `SESSION_DRIVER=redis`, `QUEUE_CONNECTION=redis`.
````
