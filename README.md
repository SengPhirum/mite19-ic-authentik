# authentik Assignment Lab

This folder contains a complete Docker Compose lab for the assignment in `authentik_assignment.docx`.

It includes:

- authentik 2026.5.0 with PostgreSQL, based on the current official Docker Compose layout.
- Grafana OSS as the OAuth2/OIDC sample application.
- A blueprint that creates demo users, groups, an OIDC provider, the Grafana application entry, and a group-based conditional access policy.
- Manual and scheduled backup support for PostgreSQL plus static directories.
- A report draft in `docs/ASSIGNMENT_REPORT.md` with all five assignment parts.

## Quick Start

1. Review `.env`.

   For local demo, the generated values already work:

   - authentik: `http://localhost:9000`
   - Grafana: `http://localhost:3000`

   For a server demo, change these three values before first start:

   ```env
   AUTHENTIK_PUBLIC_URL=http://SERVER_IP:9000
   GRAFANA_ROOT_URL=http://SERVER_IP:3000
   GRAFANA_REDIRECT_URI=http://SERVER_IP:3000/login/generic_oauth
   ```

2. Start the lab.

   ```bash
   docker compose pull
   docker compose up -d
   docker compose ps
   ```

3. Open authentik.

   Go to `http://localhost:9000/if/flow/initial-setup/` and create the `akadmin` password if the setup wizard is shown. Keep the trailing slash.

4. Confirm the blueprint objects.

   In authentik Admin UI, check:

   - Users: `demo-admin`, `demo-user`, `demo-outsider`
   - Groups: `assignment-admins`, `grafana-access`
   - Application: `Grafana Demo`
   - Provider: `grafana-oidc-provider`

5. Demo SSO with Grafana.

   Open `http://localhost:3000`, choose authentik login, and sign in as:

   - allowed user: `demo-user`
   - password: value of `DEMO_USER_PASSWORD` in `.env`

   Test denial with:

   - denied user: `demo-outsider`
   - password: value of `DEMO_OUTSIDER_PASSWORD` in `.env`

6. Enable administrator TOTP MFA.

   Do this in authentik, not Grafana.

   1. Open `http://localhost:9000`.
   2. Log in with the authentik demo administrator:
      - username: `demo-admin`
      - password: value of `DEMO_ADMIN_PASSWORD` in `.env`
   3. In the authentik user interface, click the `demo-admin` avatar/initials in the top-right corner and open the user settings page.
   4. In the left menu, select `Credentials`.
   5. In the `MFA Devices` panel, click `Enroll`, then choose the TOTP/authenticator-app option.
   6. Scan the QR code with Google Authenticator, Authy, Microsoft Authenticator, or another TOTP app.
   7. Enter the generated 6-digit code to confirm enrollment.
   8. Log out of authentik and log back in as `demo-admin`; capture the screen where authentik asks for the TOTP code as MFA proof.

## Demo Credentials

Passwords are stored in `.env` so the lab is repeatable.

- authentik demo admin: `demo-admin` / `DEMO_ADMIN_PASSWORD`
- authentik regular user: `demo-user` / `DEMO_USER_PASSWORD`
- authentik denied user: `demo-outsider` / `DEMO_OUTSIDER_PASSWORD`
- Grafana local admin fallback: `admin` / `GRAFANA_ADMIN_PASSWORD`

## Backup And Restore

Manual backup:

```bash
./scripts/backup-now.sh
```

PowerShell:

```powershell
.\scripts\backup-now.ps1
```

Scheduled daily backup with retention:

```bash
docker compose --profile backup up -d backup
```

Simulate data loss and restore:

```bash
./scripts/backup-now.sh
./scripts/simulate-data-loss.sh
./scripts/restore-db.sh backups/<timestamp>/authentik.dump
```

PowerShell restore:

```powershell
.\scripts\restore-db.ps1 backups\<timestamp>\authentik.dump
```

Static files are archived as `backups/<timestamp>/static.tar.gz`. They cover `data`, `certs`, `custom-templates`, and `blueprints`.

## Report And Screenshots

Use `docs/ASSIGNMENT_REPORT.md` as the final lab report draft. Add screenshots to `docs/screenshots/` using the checklist in `docs/screenshots/README.md`, then export the report to PDF as:

```bash
pandoc docs/ASSIGNMENT_REPORT.md -o GroupName_authentik_Assignment.pdf --toc --number-sections
```

## Useful Commands

```bash
docker compose logs -f server worker
docker compose exec worker ak dump_config
docker compose exec worker ak apply_blueprint /blueprints/assignment-lab.yaml
docker compose down
```

Do not mount over authentik's whole `/blueprints` directory. The compose file mounts only `assignment-lab.yaml` so authentik's built-in default blueprints still create the standard flows and OIDC mappings. Also do not mount `/etc/timezone` or `/etc/localtime` into authentik containers; the official docs warn this can break OAuth and SAML time handling.
