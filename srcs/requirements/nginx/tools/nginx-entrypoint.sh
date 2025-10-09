#!/bin/sh

# Generate self-signed SSL certificate if it doesn't exist
if [ ! -f "/etc/nginx/ssl/nginx-selfsigned.crt" ]; then
    echo "Generating self-signed SSL certificate..."
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout /etc/nginx/ssl/nginx-selfsigned.key \
        -out /etc/nginx/ssl/nginx-selfsigned.crt \
        -subj "/C=JO/ST=Amman/L=Amman/O=42/OU=Student/CN=${WORDPRESS_URL}"
fi

# Substitute environment variables in nginx.conf
envsubst '\$WORDPRESS_URL' < /etc/nginx/nginx.conf > /tmp/nginx.conf && mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Test nginx configuration
nginx -t

# Start nginx
echo "Starting Nginx..."
exec nginx -g 'daemon off;'