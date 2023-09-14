FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.28 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.28 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:0b6ec262d8ecca1ec4ae3de6aafd1883f63bb53d448b0f25939323f70f71bdb8  

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www/aredn-manager

RUN mkdir -p /www/map/data

RUN apk add --no-cache \
    nginx \
    cronie

RUN (crontab -l ; echo "30 * * * * node /meshmap/walk.js") | crontab -

# Install API dependencies
COPY legacy-node-api /api
RUN cd /api \
    && npm ci

COPY --chown=root:root rootfs /

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
