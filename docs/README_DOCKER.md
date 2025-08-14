# Docker Commands – What They Do (for this project)

This project runs **4 containers** in dev:

* `nginx` (serves the app on [http://localhost:8080](http://localhost:8080))
* `php` (runs Laravel)
* `mysql` (database)
* `phpmyadmin` (DB web GUI on [http://localhost:8081](http://localhost:8081))

> In all examples below we pass `--env-file .env` and the compose file we’re using.

---

## Start, Stop, Status

### Start / build (first run or after changes)

```bash
docker compose --env-file .env -f docker-compose.dev.yml up -d --build
```

* **up**: create & start containers
* **-d**: run in background (detached)
* **--build**: rebuild images if needed

### Stop (keep data/containers)

```bash
docker compose --env-file .env -f docker-compose.dev.yml down
```

### Stop and delete data (⚠ wipes DB & volumes)

```bash
docker compose --env-file .env -f docker-compose.dev.yml down -v
```

* **-v**: removes volumes (DB, composer cache)

### See what’s running

```bash
docker compose --env-file .env -f docker-compose.dev.yml ps
```

### Live logs (Ctrl+C to exit)

```bash
docker compose --env-file .env -f docker-compose.dev.yml logs -f
```

* **-f**: follow (stream)

---

## Working inside the PHP container

### Open a shell (run composer / artisan)

```bash
docker compose --env-file .env -f docker-compose.dev.yml exec php sh
```

Inside the shell you can run:

```bash
composer install
php artisan migrate
php artisan cache:clear
```

### Run one-off commands without opening a shell

```bash
docker compose --env-file .env -f docker-compose.dev.yml exec php php artisan migrate
docker compose --env-file .env -f docker-compose.dev.yml exec php composer update
```

---

## Inspecting services

### View logs for just one service

```bash
docker compose --env-file .env -f docker-compose.dev.yml logs -f php
```

### Check container resources / details

```bash
docker stats        # live CPU/mem usage
docker inspect <container_name_or_id>
```

---

## Common “why isn’t it working?” fixes

* **Ports in use**: change `DEV_HTTP_PORT` / `PHPMYADMIN_PORT` in `.env`, then `down` and `up -d`.
* **DB connection fails**: ensure DB host in `app/.env` is `mysql`, not `localhost`.
* **Permission errors on storage/**:

  ```bash
  docker compose --env-file .env -f docker-compose.dev.yml exec php sh -lc \
    "chown -R www-data:www-data /var/www/html && \
     find storage bootstrap/cache -type d -exec chmod 775 {} \; && \
     find storage bootstrap/cache -type f -exec chmod 664 {} \;"
  ```
* **Start clean (⚠️ deletes DB)**:

  ```bash
  docker compose --env-file .env -f docker-compose.dev.yml down -v
  docker compose --env-file .env -f docker-compose.dev.yml up -d --build
  ```

---

## Switching between dev and prod-like

* **Dev (recommended locally)**

  ```
  cp .env.dev .env
  docker compose --env-file .env -f docker-compose.dev.yml up -d --build
  ```

* **Prod-like (also local)**

  ```
  cp .env.prod .env
  docker compose --env-file .env -f docker-compose.prod.yml up -d --build
  ```
