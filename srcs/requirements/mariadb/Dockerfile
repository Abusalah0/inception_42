# debian version required by the subject (mentally challenged subject) :)
FROM debian:11

# install mariadb server and client
# clean up apt cache to reduce image size
# https://mariadb.com/kb/en/installing-mariadb-deb-files/
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        mariadb-server \
        mariadb-client \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /var/run/mysqld /var/lib/mysql \
    && chmod 755 /var/run/mysqld /var/lib/mysql

# copy custom config file to avoid "bind-address" error
COPY configs/mariadb.conf /etc/mysql/mariadb.conf.d/50-server.cnf

# copy entrypoint script to set root password and create database
COPY tools/mariadb-entrypoint.sh /usr/local/bin/
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf \
    && chmod +x /usr/local/bin/mariadb-entrypoint.sh

# the port mariadb server listens on
EXPOSE 3306

# Start as root to read secrets, entrypoint script runs mysqld as mysql user
ENTRYPOINT ["mariadb-entrypoint.sh"]
