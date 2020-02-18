###
# Makefile for building, testing and deploying a Dockerfile.
# Arguments can be defined either via make command line or
# the included env.mk file.
###
# > dockerd@example:~$ make build
# > dockerd@example:~$ make start NAME=CustomName
###
-include env_file

ifneq ($(DIO_TAG),)
    ifneq ($(TAG),latest)
        TAG := $(TAG)-$(DIO_TAG)
    endif
endif

.PHONY: build tags test push run start stop logs clean release

default: build tags start logs

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg TAG=$(TAG) \
		--build-arg DEBIAN_FRONTEND=noninteractive ./

tags:
	@echo 'Full tag:' $(TAG)
	@echo 'Dockerd tag:' $(DIO_TAG)
	@echo 'From tag:' $(FROM)

test:
	cd ./tests/basic && IMAGE=$(REPO):$(TAG) ENV=$(ENV) ./run.sh
	cd ./tests/php && IMAGE=$(REPO):$(TAG) ENV=$(ENV) ./run.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -it -p $(PORTS) -v $(VOLUMES) --env-file $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) -p $(PORTS) -v $(VOLUMES) --env-file $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) -p $(PORTS) -v $(VOLUMES) --env-file $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

nuke:
	docker system prune -a

release: build push

%:
	@:
