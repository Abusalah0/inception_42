# Inception Infrastructure Platform (Dockerized WordPress Stack)

Containerized multi-service infrastructure built for the 42 Inception project.
The system is designed around service isolation, secure secret handling, persistent state, and reproducible local deployment.

## Table of Contents

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Setup](#setup)
  - [Quick Start](#quick-start)
  - [Usage](#usage)
  - [Service Access](#service-access)
- [Architecture Overview](#architecture-overview)
- [Services](#services)
  - [Core Services](#core-services)
  - [Bonus Services](#bonus-services)
- [Infrastructure Considerations](#infrastructure-considerations)
  - [Networking](#networking)
  - [Data Persistence](#data-persistence)
  - [Security Considerations](#security-considerations)
  - [Design Decisions](#design-decisions)
- [References](#references)

## Getting Started

### Requirements

- Docker
- Docker Compose plugin (`docker compose`)
- Linux user with permission to run Docker

### Setup

1. Create secret files in the folder above this repository:

```text
../secrets/db_root.txt
../secrets/db_user.txt
../secrets/wp_admin.txt
../secrets/wp_user.txt
../secrets/portainer_admin.txt
```

2. Create `srcs/.env` (for example from `srcs/.env.example`) with at least:

```env
MYSQL_DATABASE=wordpress
MYSQL_USER=wpuser
WORDPRESS_DB_HOST=mariadb
WORDPRESS_URL=abdsalah.42.fr
WORDPRESS_TITLE=Inception
WORDPRESS_ADMIN_USER=admin
WORDPRESS_ADMIN_EMAIL=admin@example.com
WORDPRESS_USER=author
WORDPRESS_USER_EMAIL=author@example.com
REDIS_HOST=redis
REDIS_PORT=6379
WP_REDIS_DATABASE=0
```

3. Add your domain to `/etc/hosts`:

```text
127.0.0.1 abdsalah.42.fr
```

### Quick Start

```bash
cp srcs/.env.example srcs/.env
make
```

Open: `https://abdsalah.42.fr`

### Usage

From the repository root:

- `make` - build and start everything
- `make up` - start containers
- `make down` - stop containers
- `make re` - full rebuild without cache
- `make clean` - stop and remove volumes
- `make fclean` - stop and remove volumes and images

### Service Access

- WordPress: `https://abdsalah.42.fr`
- Adminer: `https://abdsalah.42.fr/adminer`
- Static page: `https://abdsalah.42.fr/static`
- Portainer: `https://abdsalah.42.fr:9443`
- FTP: `21`, `2121`, `30000-30009`

## Architecture Overview

High-level request path:

Client -> Nginx -> WordPress -> MariaDB
                        |
                        v
                      Redis

```text
        Client
          |
          v
     Nginx (TLS)
          |
          v
   WordPress (PHP-FPM)
      /           \
     v             v
 MariaDB         Redis

Bonus side services on the same Docker network:
  - Adminer (DB UI)
  - Portainer (container management)
  - ProFTPD (file transfer)
  - Static Site (Nginx)
```

System behavior summary:

- Nginx terminates TLS and forwards PHP requests to WordPress (PHP-FPM).
- WordPress persists application files on a shared volume and stores relational data in MariaDB.
- Redis is used as an object cache to reduce repeated database reads.
- Bonus services are attached to the same network for internal reachability and operational tooling.

## Services

### Core Services

#### Nginx

- Role: public HTTPS entrypoint and reverse proxy.
- Communication:
  - Receives external traffic on `443`.
  - Forwards PHP traffic to `wordpress:9000`.
  - Proxies `/adminer` to `adminer:8080` and `/static` to `static_site:80`.
- Why it exists:
  - Central TLS termination.
  - Single routing point for web traffic.
  - Keeps backend services off direct public exposure for normal web flow.

#### WordPress (PHP-FPM)

- Role: application runtime.
- Communication:
  - Accepts FastCGI requests from Nginx.
  - Connects to `mariadb` for persistent data.
  - Connects to `redis` for object caching.
- Why it exists:
  - Separates app logic from web server and database concerns.
  - Uses startup automation (`wp-cli`) to bootstrap config and users.

#### MariaDB

- Role: relational data store for WordPress content/users/settings.
- Communication:
  - Receives DB traffic from WordPress on the internal Docker network.
- Why it exists:
  - Durable transactional storage.
  - Decouples data lifecycle from application container lifecycle.

### Bonus Services

#### Redis

- Role: in-memory cache backend for WordPress object cache.
- Communication:
  - Accessed by WordPress via internal service name `redis`.
- Why it exists:
  - Reduces DB pressure and improves response times for repeated reads.

#### Adminer

- Role: lightweight database administration UI.
- Communication:
  - Reached through Nginx route `/adminer`.
  - Connects internally to MariaDB.
- Why it exists:
  - Enables quick schema/data inspection during development and testing.

#### Portainer

- Role: container management UI.
- Communication:
  - Uses mounted Docker socket and internal data volume.
- Why it exists:
  - Operational visibility into containers, volumes, and runtime state.

#### ProFTPD

- Role: FTP/FTPS-based file transfer endpoint.
- Communication:
  - Shares the WordPress data volume for file operations.
  - Exposes FTP and passive ports for client connectivity.
- Why it exists:
  - Supports remote file workflows against WordPress content.

#### Static Site

- Role: standalone Nginx service serving a static page.
- Communication:
  - Accessed through Nginx reverse proxy route `/static`.
- Why it exists:
  - Demonstrates additional isolated web workload within same platform.

## Infrastructure Considerations

### Networking

- All services join a dedicated bridge network: `inception`.
- Internal communication uses Docker DNS service names (`mariadb`, `wordpress`, `redis`, etc.).
- In the core request path, only Nginx is exposed for public web traffic.
- Bonus services may expose additional ports for management/testing (for example Portainer and FTP).

### Data Persistence

Persistent state is isolated from container lifecycles using bind-mounted Docker volumes:

- `mariadb_data` -> `/home/abdsalah/data/mariadb`
- `wordpress_data` -> `/home/abdsalah/data/wordpress`
- `portainer_data` -> Portainer internal state

Why volumes are used:

- Containers can be rebuilt without losing application data.
- Database durability is maintained across restarts.
- WordPress content (themes/uploads/plugins) remains stable.

Services with persistent data:

- MariaDB
- WordPress
- Portainer

### Security Considerations

- Docker secrets are used for sensitive values (DB credentials and admin passwords) instead of hardcoding values in images.
- Service isolation is enforced through separate containers and an internal network.
- TLS is enabled at Nginx with a generated certificate for encrypted transport.
- Images are intentionally minimal and only include required packages to reduce attack surface.
- Public exposure is constrained to necessary endpoints; internal services communicate over private Docker networking.

### Design Decisions

#### Docker secrets vs environment variables

- Secrets reduce accidental credential leakage in logs and image history.
- Runtime reads from `/run/secrets/*` keep credentials external to source-controlled config.

#### Bind mounts vs managed volumes

- Bind mounts provide explicit host paths for predictable data location and easy inspection.
- Useful in an educational/dev workflow where direct filesystem visibility is valuable.

#### Service separation

- Nginx, WordPress, DB, cache, and tooling are split into independent containers.
- Improves fault isolation, makes debugging clearer, and allows independent rebuild/restart.
## References

This project was built by studying and integrating best practices from the following resources:

- **Docker & Container Best Practices**
  - [Docker Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)
  - [Docker Build Best Practices](https://docs.docker.com/build/building/best-practices/)
  - [Dockerfile Best Practices](https://medium.com/@aditya_misra5/dockerfile-best-practices-1de436c966a5)
  - [Docker Dockerfile Best Practices (Historical)](https://github.com/openshift/dockerexec/blob/master/vendor/src/github.com/docker/docker/docs/sources/articles/dockerfile_best_practices.md)
  - [OCI vs Docker: What is a Container?](https://www.theodo.com/en-fr/blog/oci-vs-docker-what-is-a-container)
  - [PID 1 Handling in Kubernetes](https://about.gitlab.com/blog/how-we-removed-all-502-errors-by-caring-about-pid-1-in-kubernetes/)

- **Docker Secrets & Security**
  - [Docker Engine Swarm Secrets](https://docs.docker.com/engine/swarm/secrets/)
  - [The Twelve-Factor App](https://12factor.net/)

- **Environment Management**
  - [direnv Documentation](https://direnv.net/)

- **Service-Specific Documentation**
  - [MariaDB Documentation](https://mariadb.com/docs/)
  - [MariaDB Server Management & Automation](https://mariadb.com/docs/server/server-management/automated-mariadb-deployment-and-administration)
  - [MariaDB Container Reference](https://github.com/hhorak/mariadb-container-doc/blob/master/10.1/Dockerfile)
  - [WordPress Codex](https://codex.wordpress.org/Main_Page)
  - [WordPress CLI Handbook](https://make.wordpress.org/cli/handbook/how-to/how-to-install/)
  - [Nginx Configuration Management](https://docs.nginx.com/nginx/admin-guide/basic-functionality/managing-configuration-files/)