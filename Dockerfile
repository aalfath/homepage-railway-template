# Homepage (https://gethomepage.dev) for Railway.
# Official image, pinned by version and multi-arch index digest. Bump both together.
FROM ghcr.io/gethomepage/homepage:v2.8.0@sha256:019d8f063a7299e7c1c51ee4a70b692291809af3244894fbec2c2ac7d1f71b18

# Starter config, copied into the empty /app/config volume on first boot only.
COPY seed/ /opt/railway-seed/
COPY railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh

# Railway defaults (each can be overridden by a service variable):
# - login gate on (Homepage v2 password login), so a fresh URL never shows the dashboard to strangers
# - logs to stdout only (Railway keeps them), so log files don't fill the config volume
# - Node heap capped so the service stays inside a 0.5 GB plan
ENV HOMEPAGE_AUTH_ENABLED=true \
    LOG_TARGETS=stdout \
    NODE_OPTIONS=--max-old-space-size=320 \
    PORT=3000

# railway-start.sh seeds the config, fixes HOMEPAGE_ALLOWED_HOSTS for Railway's health
# check and then hands over to the upstream docker-entrypoint.sh.
ENTRYPOINT ["/usr/local/bin/railway-start.sh"]
CMD ["node", "server.js"]
