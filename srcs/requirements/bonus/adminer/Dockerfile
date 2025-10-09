FROM debian:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    php-common \
    php-cli \
    php-mysql \
    ca-certificates \
    && mkdir -p /var/www \
    && wget "http://www.adminer.org/latest.php" -O /var/www/adminer.php \
    && apt-get remove -y wget \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for running Adminer
RUN useradd -r -u 1000 -s /bin/false adminer \
    && chown adminer:adminer /var/www/adminer.php

WORKDIR /var/www

EXPOSE 8080

USER adminer

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "adminer.php"]