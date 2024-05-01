FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.183 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.183 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:fdba65069d38652098d9dd1c44c0a3f7c5922ee4713c5820e5681deb6447959d

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www

RUN apk add --no-cache \
    nginx

COPY --chown=root:root rootfs /

# AREDN Manager runs OLSRD on its own
RUN rm -rf /etc/s6/olsrd

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
