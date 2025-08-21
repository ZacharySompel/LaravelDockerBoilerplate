# Laravel Docker Stack (Dev + Prod-like)

This repo gives you a **ready-to-run Laravel+Statamic CMS environment** using Docker.  
It’s designed for **local development** and can be adapted for production-like setups.  

You can use it to:
- Quickly spin up a fresh Laravel project without installing PHP, Composer, or MySQL locally.
- Prototype and build Laravel-based applications.

- **Nginx** – serves the app
- **PHP-FPM** – runs PHP (Laravel)
- **MySQL 8** – database
- **phpMyAdmin** – web GUI for the DB

No global PHP/Composer/MySQL needed on your machine.

---

## Prerequisites

- Install **Docker Desktop** (Mac/Windows) or Docker Engine (Linux)

---

## TL;DR – Getting Started (DEV)

```bash
# 1) Clone the repo
git clone https://github.com/ZacharySompel/LaravelDockerBoilerplate.git .
cd laravel-stack

# 2) Copy the default dev env (used by Docker Compose)
cp .env.dev .env

# 3) Start the stack (builds images on first run)
docker compose --env-file .env -f docker-compose.dev.yml up -d --build

# 4) Initial install only — copy .env.laravel into the container (preserves APP_KEY if it already exists)
cp .env.laravel app/.env

Notes:
- Step 4 is the **only** time you need that copy command (initial project setup).  
- If you later change `.env.laravel` and want to reapply it without breaking encryption, you can rerun Step 4—your existing `APP_KEY` will be preserved.  

# 5) Ensure APP_KEY exists and clear caches
docker compose -f docker-compose.dev.yml exec php php artisan key:generate --ansi

# --- Troubleshooting ---
# If you see: "Could not open input file: artisan"
# it means Laravel dependencies haven’t been installed yet.
# Run the following to fix:

# 5.1. Enter the PHP container:
docker compose -f docker-compose.dev.yml exec php sh

# 5.2. Go to the app directory:
cd /var/www/html

# 5.3. Install dependencies:
composer install

# 5.4. Run database migrations and seeders:
php artisan migrate:fresh --seed

# 5.5. Generate app key and clear caches:
php artisan key:generate
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# 5.6. (Optional) Create your first Statamic user:
php please make:user
# If prompted to enable Statamic Pro, type "yes or no depending on your projects needs".
## Note Ctrl+D exits out of the container.

# 6) Open the app + DB admin
# App:        http://localhost:8082
# statamic:   http://localhost:8082/cp
# phpMyAdmin: http://localhost:8083

# 7) (Optional) Remove existing Git history and create your own repo
rm -rf .git
git init
git add .
git commit -m "Initial commit - Laravel Docker Stack"

---