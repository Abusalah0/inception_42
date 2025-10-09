#!/bin/sh

# Read passwords from secrets
MYSQL_ROOT_PASSWORD=$(cat /run/secrets/mysql_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/mysql_password)

# Check if database is already initialized (flag file approach)
if [ ! -f "/var/lib/mysql/.initialized" ]; then
    echo "Initializing MariaDB database..."
    
    # Initialize database system tables
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --rpm --skip-test-db
    
    # Start temporary instance for configuration
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/tmp/mysql_init.sock &
    MYSQL_PID="$!"
    
    # Wait for database to be ready
    until mysqladmin ping --socket=/tmp/mysql_init.sock --silent; do
        sleep 1
    done
    
    # Configure database
    mysql --socket=/tmp/mysql_init.sock -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '$MYSQL_USER'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Shutdown temporary instance
    kill "$MYSQL_PID"
    wait "$MYSQL_PID"
    
    # Mark as initialized
    touch /var/lib/mysql/.initialized
    echo "MariaDB initialization completed"
else
    echo "MariaDB already initialized, skipping setup"
fi

# Start MariaDB server
exec mysqld --user=mysql --datadir=/var/lib/mysql
