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
RUN chown redis:redis /etc/redis/redis.conf

# Create Redis log directory
RUN mkdir -p /var/log/redis \
    && chown redis:redis /var/log/redis

EXPOSE 6379

# Use redis user for security
USER redis

CMD ["redis-server", "/etc/redis/redis.conf"]