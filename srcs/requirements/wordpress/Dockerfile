FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    mariadb-client \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    wget

# Download and extract WordPress
RUN wget http://wordpress.org/latest.tar.gz \
    && tar -xzvf latest.tar.gz \
    && rm latest.tar.gz \
    && mv wordpress /var/www/

WORKDIR /var/wwww/wordpress

CMD ["php-fpm8.2", "-F"]