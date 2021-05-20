# make VERBOSE nonempty to see raw commands (or provide on command line)
ifndef VERBOSE
VERBOSE:=
MAKEFLAGS += --no-print-directory
endif

# use SHOW to inform user of commands
SHOW:=@echo

# use HIDE to run commands invisibly, unless VERBOSE defined
HIDE:=$(if $(VERBOSE),,@)

.PHONY: init clone perm pull build run start restart migrate test-db install init-done


##
##|------------------------------------------------------------------------|
##			Help
##|------------------------------------------------------------------------|
help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

DOCKER:= docker
DOCKER_COMPOSE:= docker-compose
SHELL:=/bin/bash
DOCKER_COMPOSE_FILE:= docker-compose.yml
INIT_TARGETS:= perm install build start db-init migrate gen-keys init-done
SERVICES:= service1 service2 service3
GIT_URL:=https://github.com/alexgagescu

#
#|------------------------------------------------------------------------|
#			Various commands
#|------------------------------------------------------------------------|
init: $(INIT_TARGETS)

##
##|------------------------------------------------------------------------|
##			Git commands
##|------------------------------------------------------------------------|

clone: ## Clone service repos, do it only first time
	$(HIDE) for s in $(SERVICES); do git clone $(GIT_URL)/$$s $$s; done

pull: ## Pull service repos
	$(HIDE) for s in $(SERVICES); do cd $$s && git pull --ff-only && cd ..; done


perm: # NOTE this is only for purpose of this demo, DO NOT DO IN PRODUCTIOON
	$(SHOW) " Password for sudo"
	$(HIDE) for s in $(SERVICES); do cd $$s && sudo chmod -R 777 storage && cd ..; done

##|------------------------------------------------------------------------|
##			Tools 
##|------------------------------------------------------------------------|

install: ## Install dependecies
	${HIDE} for s in $(SERVICES); do \
			printf "\nInstalling $$s\n\n" && docker run --rm -v ${PWD}/$$s:/app composer install; done
gen-keys: ## Generate application keys
	${HIDE} for s in service1 service2; do \
			printf "\nGenerating $$s key\n\n" && docker-compose exec $$s php artisan key:generate; done


##
##|------------------------------------------------------------------------|
##			Docker commands 
##|------------------------------------------------------------------------|

build: ## Build all or c=<name> containers in foreground
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) build $(c)

list: ## List available services
	$(SHOW) "--  Services  --"
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) config --services

run: ## Start all or c=<name> containers in foreground
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up $(c)

start: ## Start all or c=<name> containers in background
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d $(c)

stop: ## Stop all or c=<name> containers
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) stop $(c)

restart: ## Restart all or c=<name> containers
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) stop $(c)
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) up -d $(c)

status: ## Show status of containers
	$(SHOW) "--  Services  --"
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) ps

logs: ## Show logs for all or c=<name> containers
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) logs --tail=100 -f $(c)

clean:  ## Clean all data
	@$(DOCKER_COMPOSE) -f $(DOCKER_COMPOSE_FILE) down -v

prune: ## Delete dangling images
	$(SHOW) Deleting dangling docker images
	$(HIDE) docker system prune

##
##|------------------------------------------------------------------------|
##			Database commands 
##|------------------------------------------------------------------------|
migrate: ## Run database migrations
	${HIDE} docker exec service1 php artisan migrate

db-init: ## Init db
	$(HIDE) make start c=database
	$(HIDE) sleep 10
	$(HIDE) docker exec database mysql -u root -psecret \
			-e "GRANT ALL ON laravel.* TO 'laraveluser'@'%' IDENTIFIED BY 'your_laravel_db_password';" \
			-e "FLUSH PRIVILEGES;"

init-done:
	$(SHOW) " "
	$(SHOW) " --------------------------"
	$(SHOW) " Initialization done!"
	$(SHOW) " --------------------------"
	$(SHOW) " "
	$(SHOW) -e "Open service1 @ http://localhost:8080/"
	$(SHOW) -e "Open service2 @ http://localhost:8081/"
	$(SHOW) -e "Open service3 @ http://localhost:8082/"
