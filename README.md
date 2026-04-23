*This project has been created as part of the 42 curriculum by rsommer.*

# Inception

## Description

Inception is a system administration project that sets up a small infrastructure composed of multiple Docker services. The goal is to broaden knowledge of Docker by virtualizing several Docker images inside a personal virtual machine.

The stack consists of:
- **NGINX** — sole entry point, serves HTTPS (TLSv1.2/TLSv1.3) on port 443
- **WordPress + PHP-FPM** — the web application (no nginx inside)
- **MariaDB** — the relational database backend

### Design Choices

#### Virtual Machines vs Docker
Virtual Machines emulate an entire operating system including the kernel, each requiring its own OS installation. Docker containers share the host kernel and isolate only the user-space processes. This makes containers significantly lighter, faster to start, and more portable for deploying microservices.

#### Secrets vs Environment Variables
Environment variables (`.env`) store non-sensitive configuration such as usernames, domain names, and database names — values that are useful but not secret. Docker secrets (`/run/secrets/<name>`) store sensitive data (passwords, API keys) and are mounted as in-memory files accessible only inside the container at runtime, never exposed in environment listings or image layers.

#### Docker Network vs Host Network
A custom Docker bridge network (`inception`) provides DNS-based service discovery between containers (e.g., `wordpress` and `mariadb` resolve by container name). Using `network: host` would bypass this isolation and expose containers directly on the host network, which is both a security risk and forbidden by the subject.

#### Docker Volumes vs Bind Mounts
Named volumes are managed by Docker and provide a stable, portable storage abstraction — Docker handles the mount lifecycle. Bind mounts directly map a host path into a container, coupling the container to the host filesystem layout. This project uses named volumes backed by `/home/rsommer/data` to satisfy both portability (named volumes) and data persistence at a known host location.

## Instructions

### Prerequisites
- Docker and Docker Compose installed on the VM
- `make` available
- `rsommer.42.fr` must resolve to `127.0.0.1` in `/etc/hosts`

### Setup

1. Clone the repository and enter the project directory.
2. Create the secrets files (see `DEV_DOC.md`):
   ```bash
   mkdir -p secrets
   echo "<your_db_password>"    > secrets/db_password.txt
   echo "<your_root_password>"  > secrets/db_root_password.txt
   echo "<your_admin_password>" > secrets/credentials.txt
   echo "<your_user_password>"  > secrets/wp_user_password.txt
   ```
3. Add the domain to `/etc/hosts`:
   ```bash
   make hosts
   ```
4. Build and start the stack:
   ```bash
   make
   ```

This creates `/home/rsommer/data/{wordpress,mariadb}`, builds all images, and starts the stack.

### Access

- Website: `https://rsommer.42.fr`
- WordPress admin panel: `https://rsommer.42.fr/wp-admin`

### Stop

```bash
make down
```

### Full cleanup

```bash
make fclean
```

## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [NGINX docs — TLS configuration](https://nginx.org/en/docs/http/configuring_https_servers.html)
- [WordPress CLI (WP-CLI)](https://wp-cli.org/)
- [MariaDB Docker setup guide](https://mariadb.com/kb/en/installing-and-using-mariadb-via-docker/)
- [PHP-FPM configuration](https://www.php.net/manual/en/install.fpm.configuration.php)
- [PID 1 and Docker best practices](https://www.docker.com/blog/keep-nodejs-rockin-in-docker/)

### AI Usage

Claude Code (claude-sonnet-4-6) was used to assist with:
- Generating the initial Dockerfile structure for each service
- Writing the MariaDB and WordPress entrypoint scripts
- Structuring the docker-compose.yml with named volumes and secrets
- Writing documentation files

All generated content was reviewed and understood before inclusion. The architecture decisions and configuration choices reflect an understanding of the underlying technologies.
