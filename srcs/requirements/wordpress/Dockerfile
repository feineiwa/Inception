FROM debian:bookworm

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    mariadb-client \
    php8.2 \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    ca-certificates \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

    
    # Download and extract WordPress source
RUN mkdir -p /usr/src /var/www/wordpress \
    && wget http://wordpress.org/latest.tar.gz \
    && tar -xzvf latest.tar.gz \
    && rm latest.tar.gz \
    && mv wordpress /usr/src/

WORKDIR /var/www/wordpress

# Download WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

#copy php-fpm configuration file
COPY ./conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

#copy setup script
COPY ./tools/setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh

EXPOSE 9000

CMD ["/tmp/setup.sh"]

LABEL pseudo="frahenin" \
      email="frahenin@student.42antananarivo.mg" \
      description="Wordpress + PHP-FPM container for Inception project" \
      version="1.0" \
      author="frahenin" \
      license="MIT"