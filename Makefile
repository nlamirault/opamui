# SPDX-FileCopyrightText: Copyright (C) Nicolas Lamirault <nicolas.lamirault@gmail.com>
# SPDX-License-Identifier: Apache-2.0

BANNER = O P A M U I

SHELL = /bin/bash -o pipefail

DIR = $(shell pwd)

NO_COLOR=\033[0m
OK_COLOR=\033[32;01m
ERROR_COLOR=\033[31;01m
WARN_COLOR=\033[33;01m
INFO_COLOR=\033[36m
WHITE_COLOR=\033[1m

MAKE_COLOR=\033[33;01m%-20s\033[0m

.DEFAULT_GOAL := help

OK=[✅]
KO=[🔴]
WARN=[⚠️]
INFO=[🔵]

.PHONY: help
help:
	@echo -e "$(OK_COLOR)                 $(BANNER)$(NO_COLOR)"
	@echo "------------------------------------------------------------------"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "Usage: make ${INFO_COLOR}<target>${NO_COLOR}\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  ${INFO_COLOR}%-35s${NO_COLOR} %s\n", $$1, $$2 } /^##@/ { printf "\n${WHITE_COLOR}%s${NO_COLOR}\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""

guard-%:
	@if [ "${${*}}" = "" ]; then \
		echo -e "$(ERROR_COLOR)Environment variable $* not set$(NO_COLOR)"; \
		exit 1; \
	fi

check-%:
	@if $$(hash $* 2> /dev/null); then \
		echo -e "$(OK_COLOR)$(OK)$(NO_COLOR) $*"; \
	else \
		echo -e "$(ERROR_COLOR)$(KO)$(NO_COLOR) $*"; \
	fi

##@ Development

.PHONY: init
init: ## Install dependencies
	@echo -e "$(INFO)$(INFO_COLOR)[opamui] Bootstrap$(NO_COLOR)"
	@prek install

.PHONY: clean
clean: ## Clean the repository
	@echo -e "$(INFO)$(INFO_COLOR)[dune] Clean the repository$(NO_COLOR)"
	@opam exec -- dune clean

.PHONY: build
build: ## Build the application
	@echo -e "$(INFO)$(INFO_COLOR)[dune] Build the application$(NO_COLOR)"
	@opam exec -- dune build

.PHONY: install
install: ## Install the application
	@echo -e "$(INFO)$(INFO_COLOR)[dune] Install the application$(NO_COLOR)"
	@opam exec -- dune install

.PHONY: doc
doc: ## Generate odoc documentation
	@echo -e "$(INFO)$(INFO_COLOR)[dune] Generation the documentation$(NO_COLOR)"
	@opam exec -- dune build --root . @doc

.PHONY: run
run: ## Execute the application
	@echo -e "$(INFO)$(INFO_COLOR)[dune] Execute the application$(NO_COLOR)"
	@opam exec -- dune exec opamui
