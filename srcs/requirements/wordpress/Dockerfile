FROM debian:11

# Install WordPress and necessary packages
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget curl ca-certificates gnupg \
    mariadb-client \
    php-redis \
    php php-fpm php-cli php-mysql php-curl php-gd php-mbstring php-xml php-zip \
    php-intl php-bcmath php-opcache \
    && rm -rf /var/lib/apt/lists/*

# Create WordPress directory and PHP-FPM run directory
RUN mkdir -p /var/www/html /run/php \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 755 /run/php

# Install WordPress cli
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Configure PHP-FPM to listen on port 9000, instead of the default UDS socket
RUN sed -i 's/listen = \/run\/php\/php.*\.sock/listen = 0.0.0.0:9000/' /etc/php/*/fpm/pool.d/www.conf \
    && sed -i 's/;listen.owner = www-data/listen.owner = www-data/' /etc/php/*/fpm/pool.d/www.conf \
    && sed -i 's/;listen.group = www-data/listen.group = www-data/' /etc/php/*/fpm/pool.d/www.conf \
    && sed -i 's/;listen.mode = 0660/listen.mode = 0660/' /etc/php/*/fpm/pool.d/www.conf

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script
COPY ./tools/dockerfile-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dockerfile-entrypoint.sh

RUN touch /var/log/php7.4-fpm.log \
    && chown www-data:www-data /var/log/php7.4-fpm.log

EXPOSE 9000

CMD ["/usr/local/bin/dockerfile-entrypoint.sh"]
