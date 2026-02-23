#!/bin/bash

MYSQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

echo "Waiting for MariaDB..."
until mysql -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1" > /dev/null 2>&1; do
    sleep 2
done

echo "MariaDB is ready."
# Create wp-config.php if it does not exist
if [ ! -f wp-config.php ]; then
    wp config create \
        --dbname="$MYSQL_DATABASE" \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbhost="mariadb" \
        --allow-root
fi

# Install WordPress if not installed
if ! wp core is-installed --allow-root; then
    wp core install \
        --url="https://$DOMAIN_NAME" \
        --title="My Inception WordPress Site" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL" \
        --skip-email \
        --allow-root
fi

# Create normal user if not exists
if ! wp user get "$WP_USERNAME" --allow-root > /dev/null 2>&1; then
    wp user create "$WP_USERNAME" "$WP_USER_EMAIL" \
        --role=subscriber \
        --user_pass="$WP_USER_PASSWORD" \
        --allow-root
fi

chown -R www-data:www-data /var/www/wordpress
chmod -R 755 /var/www/wordpress

exec php-fpm8.2 -F