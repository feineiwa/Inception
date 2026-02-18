FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    mariadb-client \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    curl \
    wget

CMD ["php-fpm8.2", "-F"]