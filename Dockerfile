FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.170 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.170 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:fc4c5d9410082db8c13766f756d8b5a1d60690c4e6fe8018d87eb7f49cde7a0b

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www

RUN apk add --no-cache \
    nginx

COPY --chown=root:root rootfs /

# AREDN Manager runs these on its own
RUN rm -rf /etc/s6/olsrd
RUN rm -rf /etc/s6/vtund

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
