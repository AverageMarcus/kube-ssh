.DEFAULT_GOAL := default

IMAGE ?= averagemarcus/kube-ssh:latest

export DOCKER_CLI_EXPERIMENTAL=enabled

.PHONY: docker-build # Build the docker image
docker-build:
	@docker buildx create --use --name=crossplat --node=crossplat && \
	docker buildx build \
		--output "type=docker,push=false" \
		--tag $(IMAGE) \
		.

.PHONY: docker-publish # Push the docker image to the remote registry
docker-publish:
	@docker buildx create --use --name=crossplat --node=crossplat && \
	docker buildx build \
		--platform linux/386,linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64,linux/ppc64le,linux/s390x \
		--output "type=image,push=true" \
		--tag $(IMAGE) \
		.

.PHONY: install # Installs the script to you bin directory
install:
	@cp ssh.sh /usr/local/bin/kube-ssh

.PHONY: run # Run the application
run:
	@./ssh.sh

.PHONY: help # Show this list of commands
help:
	@echo "kube-ssh"
	@echo "Usage: make [target]"
	@echo ""
	@echo "target	description" | expand -t20
	@echo "-----------------------------------"
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\1	\2/' | expand -t20

default: run
