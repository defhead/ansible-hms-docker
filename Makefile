SHELL := /bin/bash

.DEFAULT_GOAL:=help

ADVANCED_CONFS = roles/hmsdocker/defaults/main/*.yml

CUSTOM_CONF_DIR = ./vars/custom

# Found and modified from: https://gist.github.com/Pierstoval/b2539c387c467c017bf2b0ace5a2e79b
# To use the "confirm" target inside another target,
# use the " if $(MAKE) -s confirm ; " syntax.
# The CI environment variable can be set to a non-empty string,
# it'll bypass this command that will "return true", as a "yes" answer.
confirm:
	REPLY="" ; \
	read -p "⚠ This will overwrite all existing files in '$(CUSTOM_CONF_DIR)', are you sure? [y/n] > " -r ; \
	if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
		printf $(_ERROR) "FAIL" "Stopping" ; \
		exit 1; \
	else \
		printf $(_TITLE) "OK" "Copying files..." ; \
		exit 0; \
	fi
_WARN := "\033[33m[%s]\033[0m %s\n"  # Yellow text for "printf"
_TITLE := "\033[32m[%s]\033[0m %s\n" # Green text for "printf"
_ERROR := "\033[31m[%s]\033[0m %s\n" # Red text for "printf"

prepare:
	@if $(MAKE) -s confirm ; then \
		mkdir -p $(CUSTOM_CONF_DIR); \
		cp -n $(ADVANCED_CONFS) $(CUSTOM_CONF_DIR); \
		mv $(CUSTOM_CONF_DIR)/main.yml $(CUSTOM_CONF_DIR)/main_custom.yml; \
	fi

check:
	@ansible-playbook -i inventory --connection local hms-docker.yml --diff --check

apply:
	@ansible-playbook -i inventory --connection local hms-docker.yml --diff

help:
	@echo make prepare :: copy vars files
	@echo make check :: check for any changes without doing anything \(diff\)
	@echo make apply :: apply any changes identified in the diff
