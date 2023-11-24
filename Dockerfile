FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.72 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.72 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:8361722ec0c79a800545c1ba209d151277a344e6900c19bf8ab84252d5529673

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
