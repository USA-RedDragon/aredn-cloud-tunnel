FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.193 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.193 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:a8951a1d2a21b5e4b49ae8e99139a546a9bca7b89064e04f7ec2735c8a6ff1d5

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www

RUN apk add --no-cache \
    nginx

COPY --chown=root:root rootfs /

# AREDN Manager runs OLSRD on its own
RUN rm -rf /etc/s6/olsrd

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
