COMPOSE = docker compose
COMPOSE_FILE = -f ./srcs/docker-compose.yml

USER = $(shell whoami)

NAME = inception

all: up

up:
	if [ ! -d /home/$(USER)/data/mariadb ]; then \
		mkdir -p /home/$(USER)/data/mariadb; \
	fi
	if [ ! -d /home/$(USER)/data/wordpress ]; then \
		mkdir -p /home/$(USER)/data/wordpress; \
	fi
	$(COMPOSE) $(COMPOSE_FILE) up --build -d

down:
	$(COMPOSE) $(COMPOSE_FILE) down

clean:
	$(COMPOSE) $(COMPOSE_FILE) down -v

fclean:
	$(COMPOSE) $(COMPOSE_FILE) down -v --rmi all
	docker builder prune -af
	docker system prune -af
	sudo rm -rf /home/$(USER)/data/mariadb/
	sudo rm -rf /home/$(USER)/data/wordpress/

re: fclean up

ps:
	docker ps -a

logs:
	$(COMPOSE) $(COMPOSE_FILE) logs -f


build:
	$(COMPOSE) $(COMPOSE_FILE) build

.PHONY: all up down clean fclean re ps logs build