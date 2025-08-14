# Nginx Basics for This Project

Nginx is the web server in our Laravel Docker stack. It handles HTTP requests, serves static files, and forwards PHP requests to the PHP-FPM container where Laravel runs.

---

## 1. What Nginx Does Here

* **Listens on port 80** – receives incoming web traffic.
* **Serves static assets** – delivers CSS, JS, and images directly.
* **Forwards PHP requests** – sends `.php` requests to PHP-FPM (Laravel).
* **Uses environment-specific configs** – `site.dev.conf` for development, `site.prod.conf` for production.

---

## 2. Key Nginx Files in This Project

* `nginx/site.dev.conf` – local development config.
* `nginx/site.prod.conf` – optimized for production.
* `docker-compose.dev.yml` / `docker-compose.prod.yml` – determines which config is mounted.

---

## 3. How It Works with Docker Compose

```yaml
nginx:
  image: nginx:1.26-alpine
  ports:
    - "8080:80"
  volumes:
    - ./app:/var/www/html
    - ./nginx/site.dev.conf:/etc/nginx/conf.d/default.conf:ro
  depends_on:
    php:
      condition: service_started
```

**Key points:**

* The Laravel `app` directory is shared into the container.
* The default Nginx config is replaced with our custom config.
* Nginx waits for PHP to be running before starting.

---

## 4. Common Commands

**View logs:**

```bash
docker compose logs nginx
```

**Restart Nginx:**

```bash
docker compose restart nginx
```

**Rebuild after config changes:**

```bash
docker compose up -d --build nginx
```

---

## 5. Troubleshooting

* **502 Bad Gateway** – PHP-FPM container might be down or misconfigured.
* **404 Not Found** – Check your Nginx `root` path matches `/var/www/html/public`.
* **Config changes not applying** – Save the file and restart Nginx.

---

## 6. Quick Glossary

* **Reverse proxy** – forwards client requests to backend services.
* **Static file** – asset served as-is without processing.
* **PHP-FPM** – PHP FastCGI Process Manager that executes Laravel code.
