FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.37 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.37 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:0a6b3960c66509f567cebc2700bb015ac08a2cab36b798655071692a6b0794ff

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
