FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.15 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.15 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:4648534ce4a6bf2d84c6eda9000c1498353dabd52672b363acda0bbfd14f037e 

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www/aredn-manager

RUN apk add --no-cache \
    nginx

# Install API dependencies
COPY legacy-node-api /api
RUN cd /api \
    && npm ci

COPY --chown=root:root rootfs /

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
