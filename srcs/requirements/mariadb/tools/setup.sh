#!/bin/bash

services mariadb start

mysql -e "CREATE DATABASE IF NOT EXISTS faneva;"
mysql -e "CREATE USER IF NOT EXISTS 'faneva'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"
mysql -e "GRANT ALL PRIVILEGES ON faneva.* TO 'faneva'@'%';"
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'faneva';"
mysql -e "FLUSH PRIVILEGES;"

mysqladmin -u root -pfaneva shutdown

exec mysqld_safe