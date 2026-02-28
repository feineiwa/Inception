FROM debian:bookworm

RUN apt-get update && \
	apt-get install -y nginx openssl netcat-openbsd procps gettext-base && \
    apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/nginx/ssl

COPY ./conf/default.conf.template /etc/nginx/templates/default.conf.template

COPY tools/generate_ssl.sh /tmp/generate_ssl.sh

RUN chmod +x /tmp/generate_ssl.sh

EXPOSE 443

ENTRYPOINT ["/tmp/generate_ssl.sh"]

LABEL pseudo="frahenin" \
	  email="frahenin@student.42antananarivo.mg" \
	  description="Nginx container for Inception project" \
	  version="1.0" \
	  author="frahenin" \
	  license="MIT"