FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.274 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:0.0.274 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:07f03b46607609bc7d2c3c0605967996cddf2c8ef4d18ff8f467190036e8a635

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
