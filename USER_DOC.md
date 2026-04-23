# User Documentation — Inception

## What services does this stack provide?

| Service   | Description                                      | Port  |
|-----------|--------------------------------------------------|-------|
| NGINX     | HTTPS reverse proxy / web server (TLSv1.2/1.3)  | 443   |
| WordPress | Blog/CMS web application                         | 9000* |
| MariaDB   | MySQL-compatible relational database             | 3306* |

*Internal ports, not exposed to the host.

NGINX is the **only entry point**. All traffic enters via port 443 over HTTPS.

---

## Starting and stopping the project

**Start the stack:**
```bash
make
```

**Stop the stack (containers down, data preserved):**
```bash
make down
```

**View running containers:**
```bash
make ps
```

**View logs:**
```bash
make logs
```

---

## Accessing the website

1. Ensure `rsommer.42.fr` resolves to `127.0.0.1` on the host:
   ```bash
   make hosts
   # or manually:
   echo "127.0.0.1 rsommer.42.fr" | sudo tee -a /etc/hosts
   ```

2. Open your browser and navigate to:
   - **Website:** `https://rsommer.42.fr`
   - **Admin panel:** `https://rsommer.42.fr/wp-admin`

> The TLS certificate is self-signed. Your browser will show a security warning — this is expected. Accept the exception to proceed.

---

## Credentials

Credentials are stored in the `secrets/` directory (gitignored, must exist on the VM):

| File                            | Purpose                         |
|---------------------------------|---------------------------------|
| `secrets/db_password.txt`       | MariaDB wordpress user password |
| `secrets/db_root_password.txt`  | MariaDB root password           |
| `secrets/credentials.txt`       | WordPress admin password        |
| `secrets/wp_user_password.txt`  | WordPress editor user password  |

WordPress users defined in `srcs/.env`:
- **Admin user:** `rsommer_wp` (password from `secrets/credentials.txt`)
- **Editor user:** `rsommer` (password from `secrets/wp_user_password.txt`)

---

## Checking that services are running correctly

```bash
# Check all containers are Up
make ps

# Check NGINX is serving HTTPS
curl -k https://rsommer.42.fr

# Check MariaDB is running
docker exec mariadb mysqladmin status -u wpuser -p$(cat secrets/db_password.txt)

# Check WordPress PHP-FPM is running
docker exec wordpress php-fpm83 -v
```
