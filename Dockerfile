FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.270 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:0.0.270 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:ec4960fda4f3110058db1ceab8fbd360c024b6cd3e269ed714c0e29babff0d6f

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www

RUN apk add --no-cache \
    nginx \
    socat

COPY --chown=root:root rootfs /

# AREDN Manager runs OLSRD on its own
RUN rm -rf /etc/s6/olsrd

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
