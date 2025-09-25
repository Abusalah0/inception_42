all: build up

build:
	docker-compose -f ./srcs/docker-compose.yml build --no-cache

up: 
	docker-compose -f ./srcs/docker-compose.yml up -d

down:
	docker-compose -f ./srcs/docker-compose.yml down

re: down up

clean :
	docker-compose -f ./srcs/docker-compose.yml down --volumes

fclean :
	docker-compose -f ./srcs/docker-compose.yml down --volumes --rmi all

.PHONY: up down re clean fclean