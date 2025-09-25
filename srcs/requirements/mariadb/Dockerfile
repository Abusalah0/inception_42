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

# copy custom config file to avoid "bind-address" error
COPY tools/db.conf /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod 644 /etc/mysql/mariadb.conf.d/50-server.cnf

# copy entrypoint script to set root password and create database
COPY tools/dockerfile-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/dockerfile-entrypoint.sh

# the port mariadb server listens on
EXPOSE 3306

# where life starts
CMD ["dockerfile-entrypoint.sh"]
