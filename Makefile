# Inception Makefile

COMPOSE = docker compose
COMPOSE_FILE = -f ./srcs/docker-compose.yml

NAME = inception

all: up

# Build and start containers
up:
	if [ ! -d /home/frahenin/data/mariadb ]; then \
		mkdir -p /home/frahenin/data/mariadb; \
	fi
	if [ ! -d /home/frahenin/data/wordpress ]; then \
		mkdir -p /home/frahenin/data/wordpress; \
	fi
	$(COMPOSE) $(COMPOSE_FILE) up --build -d

# Stop containers
down:
	$(COMPOSE) $(COMPOSE_FILE) down

# Stop and remove volumes
clean:
	$(COMPOSE) $(COMPOSE_FILE) down -v

# Full clean (containers, volumes, images)
fclean:
	$(COMPOSE) $(COMPOSE_FILE) down -v --rmi all
	sudo rm -rf /home/frahenin/data/mariadb/
	sudo rm -rf /home/frahenin/data/wordpress/

# Rebuild everything from scratch
re: fclean up

# Show running containers
# ps:
# 	$(COMPOSE) ps

# # View logs
# logs:
# 	$(COMPOSE) logs -f

.PHONY: all up down clean fclean re ps logs