.DEFAULT_GOAL := default

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
