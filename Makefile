SHELL := /bin/bash

# Borrowed from https://stackoverflow.com/questions/18136918/how-to-get-current-relative-directory-of-your-makefile
curr_dir := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Borrowed from https://stackoverflow.com/questions/2214575/passing-arguments-to-make-run
rest_args := $(wordlist 2, $(words $(MAKECMDGOALS)), $(MAKECMDGOALS))
$(eval $(rest_args):;@:)

charts := $(shell ls $(curr_dir)/charts | xargs -I{} echo -n "charts/{}")
targets := $(shell ls $(curr_dir)/hack | grep '.sh' | sed 's/\.sh//g')
$(targets):
	@$(curr_dir)/hack/$@.sh $(rest_args)

help:
	#
	# Usage:
	#
	#   * [dev] `make generate`, generate README file.
	#           - `make generate charts/hello-world` only generate docs under charts/hello-world directory.
	#
	#   * [dev] `make lint`, check style and security.
	#           - `LINT_DIRTY=true make lint` verify whether the code tree is dirty.
	#           - `make lint charts/hello-world` only verify the code under charts/hello-world directory.
	#
	#   * [dev] `make test`, execute unit testing.
	#           - `make test charts/hello-world` only test the code under charts/hello-world directory.
	#
	#   * [ci]  `make ci`, execute `make generate`, `make lint` and `make test`.
	#
	@echo


.DEFAULT_GOAL := ci
.PHONY: $(targets) charts $(charts) docs
