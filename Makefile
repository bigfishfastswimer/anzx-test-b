#!/usr/bin/make
# Project Makefile
include project.conf
export $(shell sed 's/=.*//' project.conf)

REVERSE_DATE=$(shell date +'%Y%m%d')

.PHONY: all build validate prompt

all: prompt-build

# Docker Container Build Commands
build: build-alpine build-build build-validate

build-alpine:
	@echo -e Building Alpine Root Project Container...
	docker build -t ${projectName}/alpine:${REVERSE_DATE} -f docker/alpine/Dockerfile docker/alpine
	docker tag ${projectName}/alpine:${REVERSE_DATE} ${projectName}/alpine:latest

build-build:
	@echo -e Building Project Build Container...
	docker build -t ${projectName}/build:${REVERSE_DATE} --build-arg projectName=${projectName} -f docker/build/Dockerfile docker/build
	docker tag ${projectName}/build:${REVERSE_DATE} ${projectName}/build:latest

build-validate:
	@echo -e Building Project Validation Container...
	docker build -t ${projectName}/validate:${REVERSE_DATE} --build-arg projectName=${projectName} -f docker/validate/Dockerfile docker/validate
	docker tag ${projectName}/validate:${REVERSE_DATE} ${projectName}/validate:latest


lint:
	golangci-lint run

test:
	go vet . && go test -cover -v . 
# Stack Build Commands
stack-create:
	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a create -y -t ${STACK_TEMPLATE}" scripts/container.sh

stack-update:
	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a update -y -t ${STACK_TEMPLATE}" scripts/container.sh

stack-delete:
	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a delete -y -t ${STACK_TEMPLATE}" scripts/container.sh

stack-status:
	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a status -y -t ${STACK_TEMPLATE}" scripts/container.sh

stack-validate:
	@CMDLINE="${projectName}/build:latest /project/scripts/stack.sh -a validate -y -t ${STACK_TEMPLATE}" scripts/container.sh

# Project Code Validation Commands
validate: validate-code validate-security

validate-code:
	@CMDLINE="${projectName}/validate:latest /project/scripts/validate.sh -c -d -s -y" scripts/container.sh

validate-security:
	@CMDLINE="${projectName}/validate:latest /project/scripts/validate.sh -S" scripts/container.sh

# Prompt Container Access Commands
prompt: prompt-build
prompt-root: prompt-build-root

prompt-build:
	@echo -e Starting Project Build Container With A UserPrompt...
	@CMDLINE="-i ${projectName}/build:latest /bin/bash" scripts/container.sh
	@echo Project Container Prompt Complete!

prompt-validate:
	@echo -e Starting Project Validation Container With A User Prompt...
	@CMDLINE="-i ${projectName}/validate:latest /bin/bash" scripts/container.sh
	@echo Project Container Prompt Complete!

prompt-build-root:
	@echo -e Starting Project Build Container With A UserPrompt...
	@CMDLINE="-i --user root ${projectName}/build:latest /bin/bash" scripts/container.sh
	@echo Project Container Prompt Complete!

prompt-validate-root:
	@echo -e Starting Project Validation Container With A User Prompt...
	@CMDLINE="-i --user root ${projectName}/validate:latest /bin/bash" scripts/container.sh
	@echo Project Container Prompt Complete!
