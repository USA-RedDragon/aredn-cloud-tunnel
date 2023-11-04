FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.63 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.63 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:f3da3787e5ced5725e1bd2bb681ac1ef7a21533189a605c2d4c7bbf5b090ca6f

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
