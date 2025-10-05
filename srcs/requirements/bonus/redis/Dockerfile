FROM debian:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    redis-server \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/redis \
    && chown redis:redis /var/lib/redis \
    && chmod 755 /var/lib/redis

RUN mkdir -p /etc/redis

COPY tools/redis.conf /etc/redis/redis.conf
COPY tools/dockerfile-entrypoint.sh /usr/local/bin/
RUN chown redis:redis /etc/redis/redis.conf \
    && chmod +x /usr/local/bin/dockerfile-entrypoint.sh

# Create Redis log directory
RUN mkdir -p /var/log/redis \
    && chown redis:redis /var/log/redis

EXPOSE 6379

# Start as root to read secrets, then switch to redis user in the entrypoint
CMD ["/usr/local/bin/dockerfile-entrypoint.sh"]