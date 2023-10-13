FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.30 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.28 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:da59259d24d32ccd3402e0b027f9eed86b137213c5a8a66c092532b68c84cf3b  

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www/aredn-manager

RUN mkdir -p /www/map/data

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
