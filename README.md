# reorgdemo

NOTE: Development use only! This should not be run in production!!

To clone services run:
`make clone`

To inititialzie everything run:
`make init`


To see all commands run:
`make help`

```
|------------------------------------------------------------------------|
			Help
|------------------------------------------------------------------------|
help:  Show this help.

|------------------------------------------------------------------------|
			Git commands
|------------------------------------------------------------------------|
clone:  Clone service repos, do it only first time
pull:  Pull service repos
|------------------------------------------------------------------------|
			Tools 
|------------------------------------------------------------------------|
install:  Install dependecies
gen-keys:  Generate application keys

|------------------------------------------------------------------------|
			Docker commands 
|------------------------------------------------------------------------|
build:  Build all or c=<name> containers in foreground
list:  List available services
run:  Start all or c=<name> containers in foreground
start:  Start all or c=<name> containers in background
stop:  Stop all or c=<name> containers
restart:  Restart all or c=<name> containers
status:  Show status of containers
logs:  Show logs for all or c=<name> containers
clean:   Clean all data
prune:  Delete dangling images

|------------------------------------------------------------------------|
			Database commands 
|------------------------------------------------------------------------|
migrate:  Run database migrations
db-init:  Init db

```
