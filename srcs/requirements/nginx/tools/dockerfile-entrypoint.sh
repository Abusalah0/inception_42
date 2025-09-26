#!/bin/sh

# Substitute environment variables in nginx.conf
envsubst '\$WORDPRESS_URL' < /etc/nginx/nginx.conf > /tmp/nginx.conf && mv /tmp/nginx.conf /etc/nginx/nginx.conf

# Test nginx configuration
nginx -t

# Start nginx
echo "Starting Nginx..."
exec nginx -g 'daemon off;'