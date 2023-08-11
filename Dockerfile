FROM ghcr.io/usa-reddragon/aredn-base:main

COPY --from=ghcr.io/usa-reddragon/aredn-manager:v0.0.1 /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager
COPY --from=ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.1 /app/dist /www/aredn-manager

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
