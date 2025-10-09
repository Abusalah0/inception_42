FROM debian:11

# Install Nginx and required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
        ca-certificates \
        gettext-base \
        curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/ssl \
    && chown -R www-data:www-data /var/log/nginx /var/cache/nginx

# Copy configuration files
COPY "./configs/nginx.conf" "/etc/nginx/nginx.conf"

# Copy entrypoint script
COPY ./tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod 644 /etc/nginx/nginx.conf \
    && chmod +x /usr/local/bin/nginx-entrypoint.sh

EXPOSE 443

ENTRYPOINT ["/usr/local/bin/nginx-entrypoint.sh"]
