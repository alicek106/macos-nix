HOST ?= $(shell scutil --get LocalHostName)

.DEFAULT_GOAL := help
.PHONY: help build diff switch update-unstable update gc fmt check

help: ## list all commands
	@awk -F ':.*## ' '/^[a-z-]+:.*## / { printf "  %-16s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build: ## nix configuration build. HOST 환경변수 지정해서 특정 기기로 빌드 가능.
	nix build .#darwinConfigurations.$(HOST).system

diff: build ## nix build 후 live config와 상태 비교
	nix store diff-closures /run/current-system ./result

switch: ## nix switch
	sudo -H darwin-rebuild switch --flake .#$(HOST)

update-unstable: ## flake update: only nixpkgs-unstable
	nix flake update nixpkgs-unstable

update: ## flake update for all nixpkgs
	nix flake update

gc: ## nix gc for 7d
	sudo nix-collect-garbage --delete-older-than 7d

fmt: ## nix fmt
	nix fmt .

check: ## flake check
	nix flake check
