FROM debian:11

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    redis-server \
    redis-tools \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/lib/redis \
    && chown redis:redis /var/lib/redis \
    && chmod 755 /var/lib/redis

COPY tools/redis.conf /etc/redis/redis.conf
RUN chown redis:redis /etc/redis/redis.conf

EXPOSE 6379

USER redis

ENTRYPOINT ["redis-server"]
CMD ["/etc/redis/redis.conf"]