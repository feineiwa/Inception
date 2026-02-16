FROM debian:bookworm

RUN apt-get update -y && \
	apt-get install mariadb-server -y && \
	rm -rf /var/lib/apt/lists/*

COPY ./conf/50-server.cnf /etc/mysql/mariadb.conf.d

COPY tools/setup.sh /tmp/setup.sh

RUN chmod +x /tmp/setup.sh

EXPOSE 3306

CMD [ "/tmp/setup.sh" ]