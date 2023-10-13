FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.33 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.33 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:09a2b18e5c6cd9597d23a8f7b989ced606f947aedd7a4d56bd0b3a022863acde

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
