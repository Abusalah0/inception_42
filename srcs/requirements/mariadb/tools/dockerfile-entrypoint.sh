#!/bin/sh

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "MariaDB data directory not found, initializing database..."
    
    # Initialize the database system tables
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql --rpm --skip-test-db
    
    echo "Starting temporary MariaDB instance for setup..."
    mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=/tmp/mysql_init.sock &
    MYSQL_PID="$!"

    until mysqladmin ping --socket=/tmp/mysql_init.sock --silent; do
        echo "Waiting for database to start..."
        sleep 1
    done

    echo "Database started, configuring..."

    mysql --socket=/tmp/mysql_init.sock -u root << EOF
    ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '$MYSQL_USER'@'%';
    FLUSH PRIVILEGES;
EOF

    echo "Database $MYSQL_DATABASE created and configured"
    kill "$MYSQL_PID"
    wait "$MYSQL_PID"
    echo "Database initialization completed"
    rm -f /tmp/mysql_init.sock
fi 

echo "Starting MariaDB server..."
exec mysqld --user=mysql --datadir=/var/lib/mysql
