FROM debian:bookworm

RUN apt-get update && \
    apt-get install -y php8.2-fpm

CMD ["php-fpm8.2", "-F"]