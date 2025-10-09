# debian version required by the subject (mentally challenged subject) :)
FROM debian:11

# install mariadb server and client
# clean up apt cache to reduce image size
# https://mariadb.com/kb/en/installing-mariadb-deb-files/
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# Create necessary directories and set permissions
RUN mkdir -p /var/run/mysqld \
 && chown -R mysql:mysql /var/run/mysqld \
 && chmod 755 /var/run/mysqld

# Ensure data directory exists and has correct permissions
RUN mkdir -p /var/lib/mysql \
 && chown -R mysql:mysql /var/lib/mysql \
 && chmod 755 /var/lib/mysql

# copy custom config file to avoid "bind-address" error
COPY configs/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

# copy entrypoint script to set root password and create database
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# the port mariadb server listens on
EXPOSE 3306

# Start as root to read secrets, entrypoint script runs mysqld as mysql user
CMD ["mariadb-entrypoint.sh"]
