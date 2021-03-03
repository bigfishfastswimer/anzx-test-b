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
.PHONY: build test

# all: prompt-build

# Docker Container Build Commands
build: build-runtime build-build build-validate

build-runtime: req_tag_name
	@echo -e Building Alpine Root Project Container...
	docker build --target runtime -t ${projectName}/web-app:${HASH_NAME} --build-arg TAG_NAME=$(TAG_NAME) --build-arg HASH_NAME=$(HASH_NAME) .
	docker tag ${projectName}/web-app:${HASH_NAME} ${projectName}/web-app:latest

build-runtime-ci: req_tag_name
	@echo -e Building Container with GitHub Actions.
	docker build --target runtime -t $(ECR_REGISTRY)/${PROJECT}:$(TAG_NAME) --build-arg TAG_NAME=$(TAG_NAME) --build-arg HASH_NAME=$(GIT_SHA) .
	docker push $(ECR_REGISTRY)/${projectName}:$(TAG_NAME)

dev-env:
	@echo -e Building Project dev Container and get in there..
	docker build --target dev . -t go-dev
	docker run -it -v $(current_dir)/app:/work go-dev sh

local-lint:
	docker run --rm -v $(current_dir)/app:/app -w /app golangci/golangci-lint:v1.37.1 golangci-lint run -v

test:
	cd ${appDir}; go vet . && go test -cover -v .
# Stack Build Commands
# stack-create:
# 	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a create -y -t ${STACK_TEMPLATE}" scripts/container.sh

# stack-update:
# 	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a update -y -t ${STACK_TEMPLATE}" scripts/container.sh

# stack-delete:
# 	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a delete -y -t ${STACK_TEMPLATE}" scripts/container.sh

# stack-status:
# 	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a status -y -t ${STACK_TEMPLATE}" scripts/container.sh

# stack-validate:
# 	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a validate -y -t ${STACK_TEMPLATE}" scripts/container.sh

# # Project Code Validation Commands
# validate: validate-code validate-security

# validate-code:
# 	@CMDLINE="${projectName}/validate:latest /project/scripts/validate.sh -c -d -s -y" scripts/container.sh

# validate-security:
# 	@CMDLINE="${projectName}/validate:latest /project/scripts/validate.sh -S" scripts/container.sh

# # Prompt Container Access Commands
# prompt: prompt-build
# prompt-root: prompt-build-root

# prompt-build:
# 	@echo -e Starting Project Build Container With A UserPrompt...
# 	@CMDLINE="-i ${projectName}/build:latest /bin/bash" scripts/container.sh
# 	@echo Project Container Prompt Complete!

# prompt-validate:
# 	@echo -e Starting Project Validation Container With A User Prompt...
# 	@CMDLINE="-i ${projectName}/validate:latest /bin/bash" scripts/container.sh
# 	@echo Project Container Prompt Complete!

# prompt-build-root:
# 	@echo -e Starting Project Build Container With A UserPrompt...
# 	@CMDLINE="-i --user root ${projectName}/build:latest /bin/bash" scripts/container.sh
# 	@echo Project Container Prompt Complete!

# prompt-validate-root:
# 	@echo -e Starting Project Validation Container With A User Prompt...
# 	@CMDLINE="-i --user root ${projectName}/validate:latest /bin/bash" scripts/container.sh
# 	@echo Project Container Prompt Complete!
