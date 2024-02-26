FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.176 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.176 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:409369e0f8fb0e1b654b3e62b135a910596dd383f2f33fba9edad9b754a9c240

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
