# Developer Documentation

This document explains how a developer can set up, build, run, and maintain the infrastructure from scratch.

---

## 1. Prerequisites

Before starting, make sure the following tools are installed on your machine:

| Tool | Minimum Version | Purpose |
|------|----------------|---------|
| `docker` | 20.10+ | Container runtime |
| `docker compose` | v2+ | Multi-container orchestration |
| `make` | any | Project automation |
| `git` | any | Clone the repository |

### Install Docker (Debian/Ubuntu)

1. Set up Docker's apt repository.

```bash
# Add Docker's official GPG key:
sudo apt update
sudo apt install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update
```

2. Install the Docker packages.

```bash
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

> **Note:** To verify Docker is running after installation:
> ```bash
> sudo systemctl status docker
> ```

### Allow Docker without sudo (optional)

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Verify installation

```bash
docker --version
docker compose version
make --version
```

---

## 2. Environment Configuration

### 2.1 The `.env` File

The `.env` file at the project root holds non-sensitive variables used by Docker Compose. Create it before running the project:

```bash
echo "DOMAIN_NAME=login.42.fr

MYSQL_DATABASE=xxxxxxxx
MYSQL_USER=xxxxxxx

WP_ADMIN_USER=xxxxxxx
WP_ADMIN_EMAIL=xxxxxxx

WP_USERNAME=xxxxx
WP_USER_EMAIL=xxxxxxxxxx" > .env
```

> Replace `login` with your actual 42 login and adjust values as needed.

### 2.2 Docker Secrets

Sensitive credentials are managed via **Docker Secrets**. Each secret is a plain-text file inside the `secrets/` directory. These files must be created manually and must **never** be committed to git.

```bash
mkdir -p secrets

echo "your_root_password"  > secrets/db_root_password.txt
echo "your_db_password"    > secrets/db_password.txt
echo "your_wp_admin_pass"  > secrets/wp_admin_password.txt
echo "your_wp_user_pass"   > secrets/wp_user_password.txt
```

> Secrets are mounted read-only inside containers at `/run/secrets/<secret_name>`.

### 2.3 Protect sensitive files with `.gitignore`

```bash
echo "secrets/" >> .gitignore
echo ".env"     >> .gitignore
```

---

## 3. Configuration Files

### `docker-compose.yml`

The central orchestration file. It defines the three services (`nginx`, `wordpress`, `mariadb`), the internal Docker network that isolates all inter-container communication, the volumes that persist data on the host, and the secrets references that inject credentials into containers at runtime.

### `nginx/conf/default.conf.template`

Configures the NGINX server block to listen on port 443 (HTTPS only — no HTTP fallback), enforce TLS 1.2 and TLS 1.3 exclusively via `ssl_protocols TLSv1.2 TLSv1.3`, use the self-signed certificate at `/etc/nginx/ssl/nginx.crt` and key at `/etc/nginx/ssl/nginx.key`, serve WordPress files from `/var/www/wordpress` with `index.php` as the default index, forward all `.php` requests to the WordPress container via FastCGI on port 9000 (`fastcgi_pass wordpress:9000`), and deny access to `.htaccess` files.

### `nginx/conf/generate_ssl.sh`

Entrypoint script for the NGINX container. It generates a self-signed TLS certificate using `openssl` with the domain name read from the `$DOMAIN_NAME` environment variable, then starts NGINX in the foreground with `exec nginx -g "daemon off;"`. The certificate uses a 2048-bit RSA key and is valid for 365 days.

### `wordpress/conf/setup.sh`

Entrypoint script for the WordPress container. It reads credentials from Docker Secrets at `/run/secrets/`, waits for MariaDB to become available, then installs and configures WordPress using WP-CLI. It creates the admin user and a regular subscriber user from the values defined in `.env` and secrets.

### `mariadb/conf/setup.sh`

Entrypoint script for the MariaDB container. It reads the root password from `/run/secrets/db_root_password` and the WordPress user password from `/run/secrets/db_password`. On first run it starts a temporary MariaDB instance, sets the root password, creates the WordPress database and user, grants full privileges on that database, then shuts down the temporary instance and hands off to the real MariaDB process. If the database directory already exists, initialization is skipped entirely.

---

## 4. Building and Launching the Project

All project management is done through the `Makefile`.

### Build and start all containers

```bash
make
```

or equivalently:

```bash
make all
```

This builds all Docker images from their Dockerfiles, creates volumes if they do not exist, and starts all containers in detached mode.

### Build images without starting

```bash
make build
```

### Start containers without rebuilding

```bash
make up
```

or:

```bash
docker compose up -d
```

### Stop and remove containers (keep volumes and data)

```bash
make down
```

or:

```bash
docker compose down
```

### Stop, remove containers and destroy all data

```bash
make fclean
```

or:

```bash
docker compose down -v
```

> ⚠️ This permanently deletes all WordPress files and MariaDB data.

### Full rebuild from scratch

```bash
make re
```

Equivalent to `make fclean` followed by `make all`.

---

## 5. Container and Volume Management

### Check running containers

```bash
make ps
```

or:

```bash
docker compose ps
```

### View logs for all services

```bash
make logs
```

or:

```bash
docker compose logs
```

### View logs for a specific service

```bash
docker compose logs nginx
docker compose logs wordpress
docker compose logs mariadb
```

### Follow logs in real time

```bash
docker compose logs -f
docker compose logs -f mariadb
```

### Restart a single service

```bash
docker compose restart nginx
docker compose restart wordpress
docker compose restart mariadb
```

### Open a shell inside a running container

```bash
docker exec -it nginx sh
docker exec -it wordpress sh
docker exec -it mariadb sh
```

### Run a one-off command inside a container

```bash
docker exec mariadb mariadb -u root -p
docker exec wordpress wp --info --allow-root
```

### Volume management

```bash
docker volume ls                        # list all volumes
docker volume inspect <volume_name>     # inspect a volume
docker volume rm <volume_name>          # remove a specific volume
```

### Clean up all unused Docker resources

```bash
docker system prune -a
```

> ⚠️ This removes all images, containers, and networks not currently in use.

---

## 6. Data Persistence

### Where data is stored

All persistent data lives on the **host machine** via bind mounts defined in `docker-compose.yml`:

| Service | Container path | Host path |
|---------|---------------|-----------|
| WordPress files | `/var/www/wordpress` | `/home/login/data/wordpress` |
| MariaDB database | `/var/lib/mysql` | `/home/login/data/mariadb` |

> Replace `login` with your actual username.

### How persistence works

When containers are stopped with `make down`, the host data directories remain untouched. Running `make up` again remounts the same directories and resumes with existing data.

Data is only destroyed when you explicitly run `make fclean` or `docker compose down -v`.

### Verify host data directories

```bash
ls -la /home/$USER/data/wordpress
ls -la /home/$USER/data/mariadb
```

### Inspect the database directly

```bash
docker exec -it mariadb msql -u root -p
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
```

---

## 7. TLS / HTTPS Verification

NGINX enforces HTTPS with TLS 1.2 or TLS 1.3 only. The certificate is generated at startup by `nginx-setup.sh`.

### Test the HTTPS connection

```bash
curl -k https://localhost
openssl s_client -connect localhost:443 -showcerts
```

### Confirm TLS version enforcement

```bash
openssl s_client -connect localhost:443 -tls1_2
openssl s_client -connect localhost:443 -tls1_3
```

A successful handshake confirms the version is accepted. A failed handshake confirms it is correctly rejected.

---

## 8. Debugging Common Issues

### A container exits immediately

```bash
docker compose logs <service>
```

Look for missing secrets, misconfigured environment variables, or permission errors.

### MariaDB fails to initialize

Check that all secret files exist and are not empty:

```bash
cat secrets/db_root_password.txt
cat secrets/db_password.txt
```

### WordPress shows a database connection error

MariaDB may not have finished initializing before WordPress started. Check logs:

```bash
docker compose logs mariadb
docker compose logs wordpress
```

### Port 443 is already in use

```bash
sudo lsof -i :443
sudo kill -9 <PID>
```

### Reset everything and start fresh

```bash
make fclean
make
```

---

## 9. Quick Reference

| Command | Description |
|---------|-------------|
| `make` / `make all` | Build and start all containers |
| `make build` | Build images only |
| `make up` | Start containers without rebuilding |
| `make down` | Stop and remove containers |
| `make fclean` | Stop, remove containers and volumes |
| `make re` | Full rebuild from scratch |
| `make ps` | Show container status |
| `make logs` | Show all service logs |
| `docker compose logs -f <service>` | Follow logs for one service |
| `docker compose exec <service> sh` | Open a shell in a container |
| `docker compose restart <service>` | Restart one service |
| `docker volume ls` | List all volumes |
| `docker system prune -a` | Remove all unused Docker resources |