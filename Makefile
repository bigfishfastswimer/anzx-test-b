#!/usr/bin/make
# Project Makefile
include project.conf
export $(shell sed 's/=.*//' project.conf)

ifdef TAG_NAME
req_tag_name:
else
req_tag_name:
	$(error Must give TAG_NAME, eg. v1.0.0)
endif
.PHONY: req_tag_name


HASH_NAME=$(shell git rev-parse --short HEAD)
current_dir = $(shell pwd)
.PHONY: build test local-lint local-test

# Docker Container Build Commands
build: build-runtime build-build

build-runtime: req_tag_name
	@echo -e Building Alpine Root Project Container...
	docker build --target runtime -t ${projectName}/web-app:${HASH_NAME} --build-arg TAG_NAME=$(TAG_NAME) --build-arg HASH_NAME=$(HASH_NAME) .
	docker tag ${projectName}/web-app:${HASH_NAME} ${projectName}/web-app:$(TAG_NAME)

local-run: req_tag_name build-runtime
	@echo -e Runing local Container...
	docker run -p 8080:8080 ${projectName}/web-app:$(TAG_NAME)

build-runtime-ci: req_tag_name
	@echo -e Building Container with GitHub Actions.
	docker build --target runtime -t $(ECR_REGISTRY)/${PROJECT}:$(TAG_NAME) --build-arg TAG_NAME=$(TAG_NAME) --build-arg HASH_NAME=$(HASH_NAME) .

publish-ecr:
	@echo -e Building Container with GitHub Actions.
	docker push $(ECR_REGISTRY)/${PROJECT}:$(TAG_NAME)
build-env:
	@echo -e Building Project dev Container and get in there..
	docker build --target dev . -t go-dev

dev-env: build-env
	@echo -e instantiate DEV container and mount workspace..
	docker run -it --rm  -v $(current_dir)/app:/work go-dev sh

local-lint:
	docker run --rm -v $(current_dir)/app:/app -w /app golangci/golangci-lint:v1.37.1 golangci-lint run -v

test:
	cd ${appDir}; go vet . && go test -cover -v .

local-test: build-env
	docker run --rm -v ${current_dir}:/work go-dev sh -c "cd ${appDir}; go vet . && go test -cover -v ."

local-scan: req_tag_name
	@echo -e Please ensure login to snyk FIRST with docker scan --login
	docker scan ${projectName}/web-app:$(TAG_NAME)
