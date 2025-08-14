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
git clone https://github.com/ZacharySompel/LaravelDockerBoilerplate.git laravel-stack
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
docker compose -f docker-compose.dev.yml exec php php artisan config:clear
docker compose -f docker-compose.dev.yml exec php php artisan cache:clear
docker compose -f docker-compose.dev.yml exec php php artisan route:clear
docker compose -f docker-compose.dev.yml exec php php artisan view:clear

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