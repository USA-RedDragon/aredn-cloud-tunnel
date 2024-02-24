FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.168 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.168 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:356281075fd8c1354a34d4e8e6632e70dc25310c343ba89d933ad599b5dc1f96

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
