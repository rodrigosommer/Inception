NAME		= inception

COMPOSE		= docker compose -f srcs/docker-compose.yml
DATA_DIR	= /home/rsommer/data
DOMAIN		= rsommer.42.fr

all: setup data_dirs
	$(COMPOSE) up -d --build

setup:
	@sudo sysctl -w net.ipv4.ip_unprivileged_port_start=443 2>/dev/null || true

data_dirs:
	@if [ -d /goinfre/rsommer ]; then \
		mkdir -p /goinfre/rsommer/data/wordpress; \
		mkdir -p /goinfre/rsommer/data/mariadb; \
		if [ ! -e $(DATA_DIR) ]; then ln -sf /goinfre/rsommer/data $(DATA_DIR); fi; \
	else \
		mkdir -p $(DATA_DIR)/wordpress; \
		mkdir -p $(DATA_DIR)/mariadb; \
	fi

hosts:
	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
		echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; \
		echo "Added $(DOMAIN) to /etc/hosts"; \
	else \
		echo "$(DOMAIN) already in /etc/hosts"; \
	fi

down:
	$(COMPOSE) down

re: down all

clean: down
	docker system prune -af

fclean: clean
	docker volume prune -f
	sudo rm -rf /goinfre/rsommer/data/wordpress /goinfre/rsommer/data/mariadb

logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps

.PHONY: all setup data_dirs hosts down re clean fclean logs ps
