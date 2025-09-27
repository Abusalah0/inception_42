FROM debian:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    php-common \
    php-cli \
    php-mysql \
    ca-certificates

RUN wget "http://www.adminer.org/latest.php" -O adminer.php


EXPOSE 8080

ENTRYPOINT [ "php",  "-S",  "0.0.0.0:8080",  "adminer.php" ]