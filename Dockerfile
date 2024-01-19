FROM ghcr.io/usa-reddragon/aredn-manager:v0.0.89 as aredn-manager
FROM ghcr.io/usa-reddragon/aredn-manager-frontend:v0.0.89 as aredn-manager-frontend
FROM ghcr.io/usa-reddragon/aredn-base:main@sha256:f31b23c66b281daf51872b4b48546b5170c6c7881982b2894e94d55768e93d59

COPY --from=aredn-manager /aredn-manager /usr/bin/aredn-manager
RUN chmod a+x /usr/bin/aredn-manager

COPY --from=aredn-manager-frontend /usr/share/nginx/html /www

RUN apk add --no-cache \
    nginx

COPY --chown=root:root rootfs /

# Expose ports.
EXPOSE 5525

# Define default command.
CMD ["bash", "/usr/bin/start.sh"]
