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
COPY "./configs/nginx.conf" "/etc/nginx/nginx.conf"
RUN chmod 644 /etc/nginx/nginx.conf

# Copy entrypoint script
COPY ./tools/nginx-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh

# Create nginx user directories
RUN chown -R www-data:www-data /var/log/nginx /var/cache/nginx

# Create directory for SSL certs
RUN mkdir -p /etc/nginx/ssl

# Generate self-signed cert
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout /etc/nginx/ssl/nginx-selfsigned.key \
  -out /etc/nginx/ssl/nginx-selfsigned.crt \
  -subj "/C=JO/ST=Amman/L=Amman/O=42/OU=Student/CN=${DOMAIN_NAME}"

EXPOSE 443

CMD ["/usr/local/bin/nginx-entrypoint.sh"]
