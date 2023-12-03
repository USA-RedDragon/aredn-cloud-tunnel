FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.75 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.75 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:8e9bc6436a715e7f6a4d58c5f577b8e39d1131825911aa0f5eda64ca42f84e2a

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
