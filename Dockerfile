FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.61 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.61 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:00ed8c0a911dc627c11cf929f7e23b1f31057bc66d77ca98b74c27a796c2757f

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
