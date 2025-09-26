FROM debian:11

# Install Nginx and required packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        nginx \
        openssl \
        ca-certificates \
        gettext-base \
        curl \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories
RUN mkdir -p /var/log/nginx /var/cache/nginx /etc/nginx/ssl

# Copy configuration files
COPY "./tools/nginx.conf" "/etc/nginx/nginx.conf"
RUN chmod 644 /etc/nginx/nginx.conf

# Copy entrypoint script
COPY ./tools/dockerfile-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dockerfile-entrypoint.sh

# Create nginx user directories
RUN chown -R www-data:www-data /var/log/nginx /var/cache/nginx

# Expose HTTP port (80) for now, HTTPS (443) later
EXPOSE 80

CMD ["/usr/local/bin/dockerfile-entrypoint.sh"]
