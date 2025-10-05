#!/bin/sh

cat > /etc/redis/redis.conf << EOF
bind 0.0.0.0
port 6379
protected-mode no

timeout 0
tcp-keepalive 300
daemonize no

maxmemory 256mb
maxmemory-policy allkeys-lru

save ""
appendonly no

loglevel notice
logfile /var/log/redis/redis.log

databases 16

tcp-backlog 511

dir /var/lib/redis

hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64

notify-keyspace-events Ex
EOF

# Set proper ownership
chown redis:redis /etc/redis/redis.conf

echo "Starting Redis server without authentication..."
# Switch to redis user and start Redis
exec su -s /bin/sh redis -c "redis-server /etc/redis/redis.conf"