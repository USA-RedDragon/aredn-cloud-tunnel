FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.83 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.83 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:cfbcbc837d0b83539faafc9f6bb7285d572ebfd135b853f790f7d67c14d5399a

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www

RUN mkdir -p /www/map/data

RUN apk add --no-cache \
    nginx

COPY --chown=root:root rootfs /

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
