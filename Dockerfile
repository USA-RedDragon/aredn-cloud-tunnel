FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.205 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.205 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:77a0e6b257442058e1baa87c3e3b2a1fbe748011dffbc3da1b3c6ef836d4e83f

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
