FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y nginx openssl netcat-openbsd && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY conf/default.conf /etc/nginx/sites-available/default

COPY tools/generate_ssl.sh /tmp/generate_ssl.sh

RUN chmod +x /tmp/generate_ssl.sh

EXPOSE 443

ENTRYPOINT ["/tmp/generate_ssl.sh"]