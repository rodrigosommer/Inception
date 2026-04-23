# Developer Documentation — Inception

## Prerequisites

- Docker Engine (>= 24.x)
- Docker Compose plugin (>= 2.x)
- `make`
- `openssl` (used during NGINX image build)

---

## Virtual Machine setup

This project must run inside a Virtual Machine (VirtualBox, VMware, etc.) running Debian or Ubuntu.

### Install Docker on the VM

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin make
sudo usermod -aG docker $USER
```

Log out and back in so the group change takes effect.

### Configure the domain name

The domain `rsommer.42.fr` must resolve to the VM's local IP (127.0.0.1):

```bash
make hosts
```

Or manually:

```bash
echo "127.0.0.1 rsommer.42.fr" | sudo tee -a /etc/hosts
```

---

## Setting up the environment from scratch

### 1. Clone the repository

```bash
git clone <repo-url> ~/42cursus/Inception
cd ~/42cursus/Inception
```

### 2. Create the secrets files

The secrets directory is gitignored. You must create these files manually:

```bash
mkdir -p secrets
echo "<your_db_password>"    > secrets/db_password.txt
echo "<your_root_password>"  > secrets/db_root_password.txt
echo "<your_admin_password>" > secrets/credentials.txt
echo "<your_user_password>"  > secrets/wp_user_password.txt
```

| File                            | Used by         | Purpose                         |
|---------------------------------|-----------------|---------------------------------|
| `secrets/db_password.txt`       | mariadb, wp     | MariaDB wordpress user password |
| `secrets/db_root_password.txt`  | mariadb         | MariaDB root password           |
| `secrets/credentials.txt`       | wordpress       | WordPress admin password        |
| `secrets/wp_user_password.txt`  | wordpress       | WordPress editor user password  |

> Use strong passwords in production. These files must never be committed to git.

### 3. Review configuration

Edit `srcs/.env` if you need to change:
- Domain name (`DOMAIN_NAME`)
- Database name (`MYSQL_DATABASE`)
- MySQL user (`MYSQL_USER`)
- WordPress admin/user credentials (usernames, emails, user password)

---

## Building and launching the project

```bash
# Build all images and start the stack
make

# Equivalent to:
mkdir -p /home/rsommer/data/wordpress /home/rsommer/data/mariadb
docker compose -f srcs/docker-compose.yml up -d --build
```

The Makefile creates the data directories before running compose.

---

## Useful container management commands

```bash
# List containers and their status
make ps

# Follow logs for all services
make logs

# Follow logs for a single service
docker compose -f srcs/docker-compose.yml logs -f nginx

# Open a shell inside a container
docker exec -it mariadb sh
docker exec -it wordpress sh
docker exec -it nginx sh

# Rebuild a single service
docker compose -f srcs/docker-compose.yml up -d --build nginx

# Restart a single service
docker compose -f srcs/docker-compose.yml restart wordpress
```

---

## Project data storage

All persistent data is stored on the **host machine** under `/home/rsommer/data/`:

| Path                           | Contents                      | Docker Volume  |
|--------------------------------|-------------------------------|----------------|
| `/home/rsommer/data/mariadb/`  | MariaDB database files        | `mariadb`      |
| `/home/rsommer/data/wordpress/`| WordPress PHP files & uploads | `wordpress`    |

These are **named Docker volumes** backed by bind mounts to the above paths. Docker manages them via the volume lifecycle but stores data at the host path.

To inspect a volume:
```bash
docker volume inspect inception-srcs_wordpress
docker volume inspect inception-srcs_mariadb
```

To reset all data (destructive):
```bash
make fclean
```

---

## Architecture overview

```
Internet
   |
  443 (HTTPS, TLSv1.2/1.3)
   |
[nginx container]
   |  FastCGI :9000
[wordpress container] ── /var/www/html ── (wordpress volume)
   |  MySQL :3306
[mariadb container] ─────────────────── (mariadb volume)
```

All three containers share the `inception` Docker bridge network. Service discovery uses container names as DNS hostnames (e.g., `mariadb`, `wordpress`).

---

## Secrets vs Environment Variables

- **Secrets** (`/run/secrets/<name>`): passwords (DB password, root password, WP admin password). Read at container startup via `cat /run/secrets/<name>`.
- **Environment variables** (`.env` → `env_file`): non-sensitive config (domain, DB name, usernames). Available directly as `$VAR` in the container environment.

---

## Image build notes

- All images are built from **Alpine 3.20** (penultimate stable at time of writing).
- The `latest` tag is not used.
- No passwords appear in any Dockerfile.
- The NGINX image generates a self-signed TLS certificate at build time.
- The WordPress image downloads WordPress core and WP-CLI at build time.
- Containers run their main process as PID 1 via `exec` in entrypoint scripts (no daemons, no `tail -f`, no infinite loops).
