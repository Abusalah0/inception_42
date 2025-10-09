FROM debian:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html

COPY static_page.html /var/www/html/
COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN nginx -t

EXPOSE 80

# Run nginx in foreground (daemon off) - runs as root to bind port 80
CMD ["nginx", "-g", "daemon off;"]