#!/bin/sh
# Railway wrapper for Homepage. Exits non-zero on any setup failure so Railway's
# ON_FAILURE restart policy applies.
set -eu

CONF=/app/config
mkdir -p "$CONF"

# First boot: copy the starter config into the empty volume. Existing files are never touched.
for f in /opt/railway-seed/*; do
  name=$(basename "$f")
  if [ ! -e "$CONF/$name" ]; then
    cp "$f" "$CONF/$name"
    echo "railway-start: seeded $name"
  fi
done

# Refuse to start with the login gate on but no password or secret (would leave the
# dashboard broken or open). HOMEPAGE_AUTH_ENABLED=false turns the gate off on purpose.
if [ "${HOMEPAGE_AUTH_ENABLED:-}" = "true" ]; then
  if [ -z "${HOMEPAGE_AUTH_SECRET:-}" ]; then
    echo "railway-start: HOMEPAGE_AUTH_SECRET is empty" >&2; exit 1
  fi
  if [ -z "${HOMEPAGE_AUTH_PASSWORD:-}" ] && [ -z "${HOMEPAGE_OIDC_ISSUER:-}" ]; then
    echo "railway-start: set HOMEPAGE_AUTH_PASSWORD (or the HOMEPAGE_OIDC_* variables)" >&2; exit 1
  fi
fi

# Homepage rejects requests whose Host header isn't listed. Default to the Railway
# public domain and always allow Railway's health checker.
hosts="${HOMEPAGE_ALLOWED_HOSTS:-${RAILWAY_PUBLIC_DOMAIN:-}}"
if [ "$hosts" != "*" ]; then
  case ",$hosts," in
    *,healthcheck.railway.app,*) ;;
    *) hosts="${hosts:+$hosts,}healthcheck.railway.app" ;;
  esac
fi
export HOMEPAGE_ALLOWED_HOSTS="$hosts"

if [ -z "${HOMEPAGE_EXTERNAL_URL:-}" ] && [ -n "${RAILWAY_PUBLIC_DOMAIN:-}" ]; then
  export HOMEPAGE_EXTERNAL_URL="https://${RAILWAY_PUBLIC_DOMAIN}"
fi

cd /app
exec /usr/local/bin/docker-entrypoint.sh "$@"
