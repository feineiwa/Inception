# User Documentation

This document explains how an end user or system administrator can use and manage the deployed infrastructure.

---

## 1. Services Provided by the Stack

The infrastructure provides the following services:

### NGINX
- Acts as the web server
- Handles HTTPS connections (TLS enabled)
- Serves the WordPress website
- Only exposed service to the outside

### WordPress (PHP-FPM)
- Runs the website backend
- Processes PHP requests
- Communicates internally with MariaDB

### MariaDB
- Database server
- Stores all WordPress data: users, posts, and configuration
- Not accessible from outside the Docker network

All services run inside isolated Docker containers and communicate through a secure internal Docker network.

---

## 2. Starting and Stopping the Project

The project is managed using the provided Makefile.

### Start the Infrastructure

```bash
make
```

or

```bash
make all
```

This command builds Docker images, creates volumes if needed, and starts all containers.

### Stop the Infrastructure

```bash
make down
```

This command stops all containers, removes running containers, and keeps persistent data intact.

### Rebuild the Infrastructure

```bash
make re
```

### build images

```bash
make build
```

this command build only the images which are ready for running.

Rebuilds everything from scratch.

---

## 3. Accessing the Website and Administration Panel

After starting the project:

### Website

Open a browser and go to:

```
https://login.42.fr
```

Or use your configured domain name if defined in the `.env` file.

### WordPress Administration Panel

```
https://login.42.fr/wp-admin
```

Use the WordPress administrator credentials defined during setup.

---

## 4. Locating and Managing Credentials

Sensitive credentials are securely stored using Docker Secrets.

### Database Credentials

Stored inside the container at `/run/secrets/`. Examples:

- `db_root_password`
- `db_password`

These are automatically used by MariaDB and WordPress.

these variables are stored in .env

`MYSQL_DATABASE`
`MYSQL_USER`

### WordPress Admin Credentials

Defined during container initialization via Docker secrets and environment variables (non-sensitive configuration).

these variables are stored in .env for wordpress admin and user

`WP_ADMIN_USER`
`WP_ADMIN_EMAIL`
`WP_USERNAME`
`WP_USER_EMAIL`

If credentials need to be changed:

1. Update the secret or configuration.
2. Rebuild the project:

```bash
make re
```

---

## 5. Checking That Services Are Running Correctly

### Check Running Containers

```bash
make ps
```

or

```bash
docker compose ps
```

All services should show `Up`.

### View Logs

```bash
make logs
```

or

```bash
docker compose logs
```

Logs allow you to verify that MariaDB started correctly, WordPress connected to the database, and NGINX is serving HTTPS traffic.

### Functional Check

To confirm everything works:

1. Open `https://login.42.fr`
2. Ensure the website loads correctly
3. Log into `/wp-admin`
4. Verify you can access the dashboard

If all these steps succeed, the infrastructure is running correctly.

---

## Summary

The stack provides a secure HTTPS web server (NGINX), a WordPress application, a MariaDB database, persistent storage using Docker volumes, and secure credential management using Docker Secrets. The system can be started, stopped, monitored, and maintained using simple `make` commands.