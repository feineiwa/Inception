*This project has been created as part of the 42 curriculum by frahenin.*

# INCEPTION

# Description

Inception is a system administration project focused on building a secure and fully containerized web infrastructure using **Docker** and **Docker Compose**.

The objective is to deploy a multi-service architecture composed of:

- **NGINX** (with TLS)
- **WordPress** (with PHP-FPM)
- **MariaDB**

Each service runs inside its own container to ensure isolation, security, and modularity.

Containers communicate through a dedicated Docker network, and all important data is persisted using Docker volumes.

Sensitive information (such as passwords) is managed using **Docker Secrets**, while non-sensitive configuration values are stored in a `.env` file.

All images are built from custom Dockerfiles to better understand how Docker images are created and configured instead of relying on prebuilt images.

This architecture follows containerization best practices with emphasis on:

- Service isolation
- Security
- Data persistence
- Reproducibility

---

## Architecture & Design Choices

### Service Isolation

Each service (NGINX, WordPress, MariaDB) runs in a dedicated container to ensure:{}

- Separation of concerns
- Improved security
- Independent lifecycle management
- Easier maintenance and debugging

A custom Docker bridge network enables secure inter-container communication.

Persistent data is stored using Docker volumes.

Sensitive credentials are handled via Docker Secrets, while non-sensitive configuration is defined through environment variables.

---

## Technical Comparisons & Decisions

### Virtual Machines vs Docker

| Feature        | Virtual Machines              | Docker Containers        |
|---------------|------------------------------|--------------------------|
| OS            | Full guest OS                | Shares host kernel       |
| Resource Use  | Heavy                        | Lightweight              |
| Startup Time  | Slow                         | Fast                     |
| Isolation     | Hardware-level               | Process-level            |
| Performance   | Slower                       | Near-native              |

**Decision:**  
Docker was chosen for its lightweight virtualization, fast deployment, and efficient resource usage. Full OS virtualization was unnecessary for this architecture.

---

### Secrets vs Environment Variables

| Feature        | Environment Variables | Docker Secrets |
|---------------|----------------------|----------------|
| Security      | Moderate             | High           |
| Storage       | `.env` file          | Managed by Docker |
| Visibility    | Can be exposed       | Not exposed in plain text |
| Best Use      | Non-sensitive config | Passwords & credentials |

**Decision:**  
Docker Secrets store sensitive information such as database passwords.  
Environment variables are used only for non-sensitive configuration values.

---

### Docker Bridge Network vs Host Network

| Feature          | Bridge Network | Host Network |
|------------------|---------------|--------------|
| Isolation        | Yes           | No           |
| Security         | Higher        | Lower        |
| Port Exposure    | Controlled    | Direct       |
| Communication    | Private       | Host stack   |

**Decision:**  
A bridge network isolates services.  
Only NGINX exposes ports to the host.  
MariaDB remains internal and inaccessible externally.

---

### Docker Volumes vs Bind Mounts

| Feature        | Docker Volumes | Bind Mounts |
|---------------|---------------|-------------|
| Managed By    | Docker       | Host        |
| Portability   | High         | Lower       |
| Security      | Better control | Host-dependent |
| Use Case      | Production data | Development |

**Decision:**  
Docker volumes are used for:

- MariaDB database files  
- WordPress website files  

This ensures data persists even if containers are rebuilt or removed.

---

# Instructions

## 1. Prerequisites

- Linux environment (Debian/Ubuntu recommended)
- Docker Engine
- Docker Compose
- Make

---

## 2. Docker Installation

If Docker is not installed, follow the official guide:

https://docs.docker.com/get-started/get-docker/

After installation, verify:

```bash
docker --version
docker compose version
```

Ensure:
- Docker service running
- your user hat persmission to run Docker  commands

## 3. Environment Preparation

Create the required persistent storage directory:

```bash
mkdir -p /home/login/data
```
This directory is used by Docker volumes to persist:
- Database data
- Wordpress files

## Build & Execution

The infrastructure is managed using a Makefile.

**Available Commands**
- `make` or `make all`
  Build images and start containers.

- `make down`
  Stop and remove containers.

- `make clean`
  Stop containers and remove volumes.

- `make fclean`
  Full cleanup:
  - Remove containers
  - Remove volumes
  - Remove images
  - Remove persistent data
- `make re`
  Rebuild everything from scratch.
- `make ps`
  Show running containers.
- `make logs`
  Display logs.

## Additional Documentation

This repository also contains:

- ``USER_DOC.md`` -> [End-user documentation (usage & administration)](./USER_DOC.md)
- ``DEV_DOC.md`` -> [Developer documentation (environment setup & technical details)](./DEV_DOC.md)

# Resources

Official documentation used:

- Docker - https://docs.docker.com/get-started/docker-overview/
- Docker Compose — https://docs.docker.com/compose/intro/compose-application-model/
- NGINX - https://nginx.org/en/docs/
- MariaDB - https://www.tutorialspoint.com/mariadb/index.htm/
- WordPress - https://learn.wordpress.org/learning-pathway/user/
- wp-cli - https://developer.wordpress.org/cli/commands/
- https config - https://nginx.org/en/docs/http/configuring_https_servers.html/
- what is https - https://www.cloudflare.com/learning/ssl/what-is-https/
- php-fpm config - https://www.php.net/manual/en/install.fpm.configuration.php
- wordpress tools - https://www.atlantic.net/vps-hosting/how-to-install-wordpress-ubuntu-14/#step-1-set-up-the-mysql-database-in-ubuntu-14-04

- TLS 1.2 & TLS 1.3
https://www.geeksforgeeks.org/computer-networks/differences-between-tls-1-2-and-tls-1-3/ | 
https://developer.mozilla.org/en-US/docs/Web/Security/Defenses/Transport_Layer_Security



# Use of AI

Artificial Intelligence was used as a support tool for:

- Understanding Docker concepts
- Improving documentation clarity
- Reviewing explanations for readability

All infrastructure configuration, Dockerfiles, and implementation were manually developed and tested.