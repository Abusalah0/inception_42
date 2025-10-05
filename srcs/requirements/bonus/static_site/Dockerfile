FROM debian:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    nginx \
    curl \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html

COPY static_page.html /var/www/html/
RUN chown www-data:www-data /var/www/html/static_page.html

COPY ./conf/nginx.conf /etc/nginx/nginx.conf

RUN chown -R www-data:www-data /var/lib/nginx \
    && chown -R www-data:www-data /var/log/nginx \
    && mkdir -p /var/cache/nginx \
    && chown -R www-data:www-data /var/cache/nginx

EXPOSE 80

# Test nginx configuration
RUN nginx -t

CMD ["nginx", "-g", "daemon off;"]