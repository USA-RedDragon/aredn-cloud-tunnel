FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.185 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.185 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:82f07faf9657c9667a1e62d1aafca6f595d4cf53ba31d1bacc28152c4becc00a

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
