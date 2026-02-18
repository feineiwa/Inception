FROM debian:bookworm

RUN apt-get update -y && \
	apt-get install mariadb-server -y && \
	rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d

COPY tools/setup.sh /temp/setup.sh

RUN chmod +x /temp/setup.sh

EXPOSE 3306

CMD [ "/temp/setup.sh" ]

LABEL pseudo="frahenin" \
	  email="frahenin@student.42antananarivo.mg" \
	  description="This is the Dockerfile for the MariaDB service in the Inception project. \
		It sets up a MariaDB server with the necessary configurations and exposes the default\ 
		port for database connections." \
	  version="1.0" \
	  maintainer="frahenin" \
	  license="MIT"