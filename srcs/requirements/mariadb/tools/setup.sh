#!/bin/bash

MYSQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
MYSQL_PASSWORD=$(cat /run/secrets/db_password)

DATADIR=/var/lib/mysql

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chmod 755 /run/mysqld

if [ ! -d "$DATADIR/$MYSQL_DATABASE" ]; then
    echo "[INFO] Initializing MariaDB..."
    mysqld_safe &

    # Wait for MariaDB to be ready
    until mysqladmin ping --silent; do
        sleep 1
    done

    # Apply root password and create WP user/database
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    # Stop temporary MariaDB instance
    mysqladmin -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown
fi

exec mariadbd --user=mysql