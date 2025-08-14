# Laravel Basics for This Project

Laravel is the PHP framework running inside our Docker stack. This guide covers the most common Laravel commands and workflows you'll use.

---

## 1. Artisan CLI

Laravel's command-line interface is called **Artisan**. You run it inside the PHP container:

```bash
docker compose exec php php artisan <command>
```

---

## 2. Common Artisan Commands

**Check Laravel version:**

```bash
docker compose exec php php artisan --version
```

**Clear cache:**

```bash
docker compose exec php php artisan cache:clear
```

**Clear config cache:**

```bash
docker compose exec php php artisan config:clear
```

**Run database migrations:**

```bash
docker compose exec php php artisan migrate
```

**Rollback last migration:**

```bash
docker compose exec php php artisan migrate:rollback
```

**Create a new controller:**

```bash
docker compose exec php php artisan make:controller MyController
```

**Start Laravel Tinker (REPL):**

```bash
docker compose exec php php artisan tinker
```

---

## 3. Composer

Composer manages PHP dependencies. Run it inside the PHP container:

**Install dependencies:**

```bash
docker compose exec php composer install
```

**Add a package:**

```bash
docker compose exec php composer require vendor/package
```

**Update dependencies:**

```bash
docker compose exec php composer update
```

---

## 4. Storage & Permissions

**Link storage folder:**

```bash
docker compose exec php php artisan storage:link
```

Ensure the `storage` and `bootstrap/cache` directories are writable by the web server.

---

## 5. Environment Configuration

Laravel uses an `.env` file to store environment variables. For local development, this is generated automatically on first run. For production, update `.env` with real credentials.

**Example:**

```
APP_NAME=Laravel
APP_ENV=local
APP_KEY=base64:...
APP_DEBUG=true
APP_URL=http://localhost
```

---

## 6. Useful Tips

* Always run Artisan commands inside the PHP container to ensure the correct PHP version and extensions are used.
* Clear caches after changing config or routes.
* Use migrations to manage database schema changes consistently across environments.
