VOLUME_DIRS = /home/abdsalah/data/mariadb /home/abdsalah/data/wordpress

all: build up

build:
	docker-compose -f ./srcs/docker-compose.yml build --no-cache

create-dirs:
	mkdir -p $(VOLUME_DIRS)

up: create-dirs
	docker-compose -f ./srcs/docker-compose.yml up -d

down:
	docker-compose -f ./srcs/docker-compose.yml down

re: down up

clean :
	docker-compose -f ./srcs/docker-compose.yml down --volumes

fclean :
	docker-compose -f ./srcs/docker-compose.yml down --volumes --rmi all

.PHONY: up down re clean fclean all build create-dirs