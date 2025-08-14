# Production Deployment Guide

This guide explains how to deploy the Laravel + Nginx + MySQL + phpMyAdmin stack to a production environment.

---

## 1. Preparing for Production

Before deploying:

* Ensure your `.env.prod` file has **secure credentials** and correct database details.
* Disable `AUTO_INSTALL` in `docker-compose.prod.yml`.
* Use production-optimized PHP settings.
* Set `APP_ENV=production` and `APP_DEBUG=false`.

---

## 2. Deploying to a Bare-Metal or VPS Server

**Steps:**

1. Install Docker and Docker Compose.
2. Clone the repository:

   ```bash
   git clone <your_repo_url>
   cd <project_folder>
   ```
3. Copy `.env.prod.example` to `.env.prod` and update variables.
4. Start containers:

   ```bash
   docker compose -f docker-compose.prod.yml up -d --build
   ```
5. Set correct permissions for Laravel:

   ```bash
   docker exec <php_container> chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
   ```

---

## 3. Deploying to AWS EC2

**Recommended Instance:**

* **t3.small** or higher for small projects.
* Amazon Linux 2023 or Ubuntu 22.04.

**Steps:**

1. Launch an EC2 instance and open ports 80 and 443 in the security group.
2. SSH into the server and install Docker + Docker Compose.
3. Follow the same steps as in Bare-Metal deployment.
4. (Optional) Attach an **Elastic IP** for a fixed public IP.
5. Configure your domain’s DNS to point to the EC2 IP.

---

## 4. Deploying to AWS ECS (Optional)

* Create an ECS cluster.
* Push your Docker images to **Amazon ECR**.
* Define services and tasks in ECS with Nginx, PHP, MySQL.
* Use AWS RDS for managed MySQL instead of a container.

---

## 5. Hardening Checklist

* Use **HTTPS** with Let’s Encrypt or AWS ACM.
* Restrict database access to internal network only.
* Regularly update containers (`docker compose pull`).
* Enable **fail2ban** or firewall rules.
* Use a backup strategy for MySQL.

---

## 6. Deployment Summary

1. Prepare `.env.prod`.
2. Build and run containers with `docker-compose.prod.yml`.
3. Point domain DNS to the server IP.
4. Secure with HTTPS.
5. Monitor logs and performance.
