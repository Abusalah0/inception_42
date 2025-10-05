#!/bin/sh

# Read passwords from secrets
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)
WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password)

# Change to WordPress directory
cd /var/www/html

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "WordPress not found, initializing..."

    # Wait for MySQL to be available
    until mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
        echo "Waiting for database connection..."
        sleep 5
    done

    # Wait for Redis to be available
    until timeout 5 bash -c '</dev/tcp/redis/6379'; do
        echo "Waiting for Redis connection..."
        sleep 5
    done

    echo "Database and Redis are available, setting up WordPress..."

    # Download WordPress core files
    # if [ -z "$(ls -A /var/www/html)" ]; then
    wp core download
    # fi

    # Create wp-config.php file
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST"

    # Configure Redis settings (no password required)
    wp config set WP_REDIS_HOST "$REDIS_HOST"
    wp config set WP_REDIS_PORT "$REDIS_PORT" --raw
    wp config set WP_REDIS_DATABASE "$WP_REDIS_DATABASE" --raw
    wp config set WP_CACHE true --raw

    # Install WordPress
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email

    # After wp core install
    wp plugin install redis-cache --activate

    # Enable Redis in WordPress
    wp redis enable

    echo "WordPress initialized successfully"
fi

echo "Starting PHP-FPM..."
# Use the correct PHP-FPM binary
exec /usr/sbin/php-fpm7.4 -F