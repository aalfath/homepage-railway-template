[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/homepage-3?utm_medium=integration&utm_source=button&utm_campaign=homepage)

# Homepage on Railway

One-click [Homepage](https://gethomepage.dev) (`gethomepage/homepage`), a customisable start page for your services, with service widgets, bookmarks and status checks.

## What this template deploys

| | |
|---|---|
| App | Homepage **v2.8.0**, official image `ghcr.io/gethomepage/homepage:v2.8.0@sha256:019d8f06…f71b18` (pinned by version and digest) |
| Service | One Railway service built from this repo, public on port 3000, health check `/api/healthcheck` |
| Storage | Railway volume at `/app/config`: every YAML config file lives there and survives redeploys |
| Login | Homepage's built-in password login is on. The password is generated per deploy |
| Starter config | A small dashboard (settings, a services group, info widgets, bookmarks), copied into the empty volume on the first boot only. Your later edits are never overwritten |

No database. Homepage keeps all state in its config files.

## Variables

| Variable | Default | What it does |
|---|---|---|
| `HOMEPAGE_AUTH_PASSWORD` | `${{secret(24,...)}}` | Your login password. Read it in the service's **Variables** tab |
| `HOMEPAGE_AUTH_SECRET` | `${{secret(48)}}` | Signs the login cookies |
| `HOMEPAGE_EXTERNAL_URL` | `https://${{RAILWAY_PUBLIC_DOMAIN}}` | Public URL, used for the login redirect and secure cookies |
| `HOMEPAGE_ALLOWED_HOSTS` | `${{RAILWAY_PUBLIC_DOMAIN}}` | Host names Homepage answers on. Add your custom domain here, comma-separated. `healthcheck.railway.app` is always added for Railway's health check |
| `PORT` | `3000` | Port Homepage listens on |

The deploy form asks nothing. Set in the image (override with a service variable if you need to): `HOMEPAGE_AUTH_ENABLED=true`, `LOG_TARGETS=stdout` (logs go to Railway, not to the volume), `NODE_OPTIONS=--max-old-space-size=320`.

Optional, not set by the template: OIDC login (`HOMEPAGE_OIDC_ISSUER`, `HOMEPAGE_OIDC_CLIENT_ID`, `HOMEPAGE_OIDC_CLIENT_SECRET`), the MCP endpoint (`HOMEPAGE_MCP_ENABLED`), and your own `HOMEPAGE_VAR_*` secrets for widget API keys. See the [Homepage docs](https://gethomepage.dev/installation/#security-authentication).

## After deploying

1. Open the service's public URL and sign in with `HOMEPAGE_AUTH_PASSWORD`.
2. Edit the YAML files in `/app/config` (`services.yaml`, `widgets.yaml`, `bookmarks.yaml`, `settings.yaml`). Use `railway ssh` into the service, or Homepage's MCP endpoint. Changes show within seconds, no restart.
3. Keep API keys for widgets in Railway variables named `HOMEPAGE_VAR_<NAME>` and write `{{HOMEPAGE_VAR_<NAME>}}` in the YAML.

Docker and Kubernetes auto-discovery need a Docker socket or cluster access, which Railway services don't have. Use the HTTP/API service widgets and `siteMonitor` checks instead.

## Resources

Runs in 0.5 GB RAM (Railway Free and Trial plans). Measured on Railway with a 0.5 GB / 1 vCPU limit: about 110–170 MB after sign-in and a few page loads.

## Updates

This template builds from this repo. When the pinned Homepage version is bumped on `main`, Railway shows everyone who deployed it an "update available" notice, and you choose when to apply it. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed at the top of each entry. Your `/app/config` volume is kept across updates.

## Files

- `Dockerfile`: the pinned official image plus the wrapper.
- `railway-start.sh`: seeds the starter config on first boot, checks the login settings, adds Railway's health-check host, then runs the upstream entrypoint.
- `seed/`: the starter config.

Homepage is GPL-3.0, by the [gethomepage](https://github.com/gethomepage/homepage) project. This wrapper is not affiliated with it.
