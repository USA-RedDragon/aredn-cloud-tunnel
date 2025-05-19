FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.272 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:0.0.272 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:2d66dda3773ef0ba92b8d8af3c9c3f94c1dd3e0d04eaba02a9c0b56da015584e

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
