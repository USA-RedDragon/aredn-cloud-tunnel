FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.266 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.266 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:bd920450cc5a07c70f9cc654c393c440539b883edc470272bd2a2291213780b5

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
