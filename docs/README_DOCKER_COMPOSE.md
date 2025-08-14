# Docker Compose Basics for Laravel Projects

This guide explains **what Docker Compose is**, **how it works**, and **how to use it** for our Laravel setup.

---

## 1. What is Docker Compose?

Docker Compose is a tool that lets you **define and run multi-container Docker applications** using a single YAML file (`docker-compose.yml`).

Instead of manually running multiple `docker run` commands for each service (e.g., PHP, MySQL, Nginx), we define them in one file and start them all with:

```bash
docker compose up -d
```

---

## 2. Why are we using it?

Laravel needs **multiple services** to run:

* **PHP**: Runs Laravel code.
* **Nginx**: Serves the Laravel application to the browser.
* **MySQL**: Database for Laravel.
* **phpMyAdmin**: Web interface to manage MySQL.

Docker Compose lets us:

* Start them all at once.
* Link them together on a shared network.
* Easily switch between **dev** and **prod** environments.

---

## 3. Common Commands

### Start the containers (detached mode)

```bash
docker compose up -d
```

### Stop the containers

```bash
docker compose down
```

### View logs for all containers

```bash
docker compose logs -f
```

### Rebuild containers after changing Dockerfiles

```bash
docker compose build --no-cache
```

### Run an interactive shell inside a container

```bash
docker compose exec php sh
```

### Check running containers

```bash
docker ps
```

---

## 4. File Structure Example

```
project/
│   docker-compose.dev.yml
│   docker-compose.prod.yml
│   .env.dev
│   .env.prod
│
├── app/                 # Laravel app code
├── php/                 # PHP Dockerfiles & config
├── nginx/               # Nginx configs
└── mysql/               # Optional SQL scripts
```

---

## 5. Networks & Volumes

**Networks**

* Allow containers to talk to each other using service names (e.g., `mysql` instead of `127.0.0.1`).
* Example: `app_net_dev` for development.

**Volumes**

* Persist data even if containers are stopped or rebuilt.
* Example: `mysql-data` keeps MySQL database files.

---

## 6. Dev vs Prod

We have **two separate compose files**:

* `docker-compose.dev.yml` → With hot-reload features, auto-install Laravel, Xdebug option.
* `docker-compose.prod.yml` → Optimized for production, no auto-install.

Run dev:

```bash
docker compose -f docker-compose.dev.yml up -d
```

Run prod:

```bash
docker compose -f docker-compose.prod.yml up -d
```

---

## 7. phpMyAdmin Access

* URL: `http://localhost:8081`
* Username: From `.env` → `MYSQL_USER`
* Password: From `.env` → `MYSQL_PASSWORD`

---

## 8. Stopping & Cleaning Up

Stop containers but keep volumes:

```bash
docker compose down
```

Stop containers **and remove volumes** (deletes DB data):

```bash
docker compose down -v
```

---

## 9. Helpful Tips

* Always keep `.env.dev` and `.env.prod` with correct credentials.
* If something breaks, try `docker compose down -v` then `docker compose up -d`.
* Use `docker compose exec` to run Artisan commands:

```bash
docker compose exec php php artisan migrate
```

---