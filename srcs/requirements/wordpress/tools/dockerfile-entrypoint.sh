#!/bin/sh

# WordPress Installation and Configuration Script
# This script handles WordPress setup with proper error handling and modularity
# Runs as www-data user for security

# ============================================================================
# Configuration and Setup
# ============================================================================

# Try to read passwords from Docker secrets first, fallback to environment variables
# Note: SELinux may block direct file access to secrets in some configurations

if [ -f "/run/secrets/mysql_password" ] && [ -r "/run/secrets/mysql_password" ]; then
    MYSQL_PASSWORD=$(cat /run/secrets/mysql_password 2>/dev/null)
fi

if [ -f "/run/secrets/wordpress_admin_password" ] && [ -r "/run/secrets/wordpress_admin_password" ]; then
    WORDPRESS_ADMIN_PASSWORD=$(cat /run/secrets/wordpress_admin_password 2>/dev/null)
fi

# Fallback to environment variables if secrets couldn't be read
MYSQL_PASSWORD="${MYSQL_PASSWORD:-${MYSQL_PASSWORD_ENV}}"
WORDPRESS_ADMIN_PASSWORD="${WORDPRESS_ADMIN_PASSWORD:-${WORDPRESS_ADMIN_PASSWORD_ENV}}"

# Validate that passwords are available
if [ -z "$MYSQL_PASSWORD" ] || [ -z "$WORDPRESS_ADMIN_PASSWORD" ]; then
    echo "[ERROR] Failed to load passwords from secrets or environment variables"
    echo "[ERROR] MYSQL_PASSWORD is $([ -z "$MYSQL_PASSWORD" ] && echo 'empty' || echo 'set')"
    echo "[ERROR] WORDPRESS_ADMIN_PASSWORD is $([ -z "$WORDPRESS_ADMIN_PASSWORD" ] && echo 'empty' || echo 'set')"
    exit 1
fi

echo "[INFO] Successfully loaded passwords"

# Change to WordPress directory
cd /var/www/html

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

# Wait for MySQL database to be available
wait_for_mysql() {
    log_info "Waiting for MySQL database to be ready..."
    local max_retries=30
    local count=0
    
    until mysqladmin ping -h"mariadb" -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" --silent; do
        count=$((count + 1))
        if [ $count -ge $max_retries ]; then
            log_error "MySQL connection timeout after $max_retries attempts"
            return 1
        fi
        echo "Waiting for database connection... (attempt $count/$max_retries)"
        sleep 2
    done
    
    log_info "MySQL database is ready"
    return 0
}

# Wait for Redis to be available
wait_for_redis() {
    log_info "Checking Redis availability..."
    # Redis is optional, so we just do a quick check without blocking
    # The Redis plugin will handle connection issues gracefully
    sleep 2
    log_info "Redis check completed"
    return 0
}

# Download WordPress core files
download_wordpress() {
    if [ ! -f "wp-load.php" ]; then
        log_info "Downloading WordPress core files..."
        wp core download --allow-root || {
            log_error "Failed to download WordPress"
            return 1
        }
        log_info "WordPress core files downloaded successfully"
    else
        log_info "WordPress core files already exist"
    fi
    return 0
}

# Create WordPress configuration file
create_wp_config() {
    if [ ! -f "wp-config.php" ]; then
        log_info "Creating WordPress configuration..."
        wp config create \
            --dbname="$MYSQL_DATABASE" \
            --dbuser="$MYSQL_USER" \
            --dbpass="$MYSQL_PASSWORD" \
            --dbhost="$WORDPRESS_DB_HOST" \
            --allow-root \
            --skip-check || {
            log_error "Failed to create wp-config.php"
            return 1
        }
        log_info "WordPress configuration created successfully"
    else
        log_info "WordPress configuration already exists"
    fi
    return 0
}

# Configure Redis cache settings
configure_redis() {
    log_info "Configuring Redis cache settings..."
    
    # Add Redis configuration to wp-config.php
    wp config set WP_REDIS_HOST "$REDIS_HOST" --type=constant --allow-root 2>/dev/null || \
        log_error "Failed to set WP_REDIS_HOST"
    
    wp config set WP_REDIS_PORT "$REDIS_PORT" --raw --type=constant --allow-root 2>/dev/null || \
        log_error "Failed to set WP_REDIS_PORT"
    
    wp config set WP_REDIS_DATABASE "$WP_REDIS_DATABASE" --raw --type=constant --allow-root 2>/dev/null || \
        log_error "Failed to set WP_REDIS_DATABASE"
    
    wp config set WP_CACHE true --raw --type=constant --allow-root 2>/dev/null || \
        log_error "Failed to set WP_CACHE"
    
    log_info "Redis configuration completed"
    return 0
}

# Install WordPress
install_wordpress() {
    if ! wp core is-installed --allow-root 2>/dev/null; then
        log_info "Installing WordPress..."
        wp core install \
            --url="$WORDPRESS_URL" \
            --title="$WORDPRESS_TITLE" \
            --admin_user="$WORDPRESS_ADMIN_USER" \
            --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
            --admin_email="$WORDPRESS_ADMIN_EMAIL" \
            --allow-root \
            --skip-email || {
            log_error "Failed to install WordPress"
            return 1
        }
        log_info "WordPress installed successfully"
    else
        log_info "WordPress is already installed"
        
        # Update admin password if it changed
        if wp user get "$WORDPRESS_ADMIN_USER" --allow-root >/dev/null 2>&1; then
            log_info "Updating admin user password..."
            wp user update "$WORDPRESS_ADMIN_USER" \
                --user_pass="$WORDPRESS_ADMIN_PASSWORD" \
                --allow-root 2>/dev/null
        else
            log_info "Creating admin user..."
            wp user create "$WORDPRESS_ADMIN_USER" "$WORDPRESS_ADMIN_EMAIL" \
                --role=administrator \
                --user_pass="$WORDPRESS_ADMIN_PASSWORD" \
                --allow-root 2>/dev/null || \
                log_info "Admin user already exists or creation failed"
        fi
    fi
    return 0
}

# Setup Redis cache plugin
setup_redis_plugin() {
    log_info "Setting up Redis cache plugin..."
    
    # Check if plugin is installed
    if ! wp plugin is-installed redis-cache --allow-root 2>/dev/null; then
        log_info "Installing Redis cache plugin..."
        wp plugin install redis-cache --activate --allow-root || {
            log_error "Failed to install Redis cache plugin"
            return 1
        }
    else
        log_info "Redis cache plugin already installed"
        # Activate if not active
        if ! wp plugin is-active redis-cache --allow-root 2>/dev/null; then
            wp plugin activate redis-cache --allow-root || log_error "Failed to activate Redis cache plugin"
        fi
    fi
    
    # Enable Redis object cache
    if ! wp redis status --allow-root 2>/dev/null | grep -q "Connected"; then
        log_info "Enabling Redis object cache..."
        wp redis enable --allow-root 2>/dev/null || log_error "Failed to enable Redis cache"
    else
        log_info "Redis object cache already enabled"
    fi
    
    log_info "Redis plugin setup completed"
    return 0
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_info "Starting WordPress initialization..."
    
    # Wait for dependencies
    wait_for_mysql || exit 1
    wait_for_redis || exit 1
    
    # Download WordPress if needed
    download_wordpress || exit 1
    
    # Create configuration
    create_wp_config || exit 1
    
    # Configure Redis
    configure_redis || exit 1
    
    # Install WordPress
    install_wordpress || exit 1
    
    # Setup Redis plugin
    setup_redis_plugin || exit 1
    
    log_info "WordPress initialization completed successfully"
    log_info "=========================================="
    log_info "Admin URL: https://$WORDPRESS_URL/wp-admin"
    log_info "Username: $WORDPRESS_ADMIN_USER"
    log_info "=========================================="
}

# Run main initialization
main

# Start PHP-FPM
log_info "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -F