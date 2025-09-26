#!/bin/sh

# Change to WordPress directory
cd /var/www/html

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "WordPress not found, initializing..."

    # Wait for MySQL to be available
    until mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
        echo "Waiting for database connection..."
        sleep 5
    done

    echo "Database is available, setting up WordPress..."

    # Download WordPress core files
    if [ -z "$(ls -A /var/www/html)" ]; then
        wp core download --allow-root
    fi

    # Create wp-config.php file
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="$WORDPRESS_DB_HOST" \
        --allow-root

    # Install WordPress
    wp core install \
        --url="$WORDPRESS_URL" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL" \
        --skip-email \
        --allow-root

    echo "WordPress initialized successfully"
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html
find /var/www/html -type d -exec chmod 755 {} \;
find /var/www/html -type f -exec chmod 644 {} \;

echo "Starting PHP-FPM..."
# Use the correct PHP-FPM binary
exec /usr/sbin/php-fpm7.4 -F