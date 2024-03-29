FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.178 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.178 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:2f4b3fc55b33e7173b97ffceb05dd921f7be9b05fc65abb212dbfa50a2136552

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
