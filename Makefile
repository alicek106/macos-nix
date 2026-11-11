HOST ?= $(shell scutil --get LocalHostName)

.DEFAULT_GOAL := help
.PHONY: help build diff switch update-unstable update gc fmt check

help:
	@awk -F ':.*## ' '/^[a-z-]+:.*## / { printf "  %-16s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build:
	nix build .#darwinConfigurations.$(HOST).system

diff: build
	nix store diff-closures /run/current-system ./result

switch:
	sudo -H darwin-rebuild switch --flake .#$(HOST)

update-unstable:
	nix flake update nixpkgs-unstable

update:
	nix flake update

gc:
	sudo nix-collect-garbage --delete-older-than 7d

fmt:
	nix fmt .

check:
	nix flake check
