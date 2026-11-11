# 자주 사용하는 nix-darwin 명령. `make` 만 입력하면 명령 목록을 보여 준다.
# 호스트는 현재 맥의 LocalHostName 으로 정하고, 다른 호스트를 빌드하려면 `make build HOST=alicek106-m1` 처럼 지정한다.

HOST ?= $(shell scutil --get LocalHostName)

.DEFAULT_GOAL := help
.PHONY: help build diff switch update-unstable update gc fmt check

help: ## 명령 목록
	@awk -F ':.*## ' '/^[a-z-]+:.*## / { printf "  %-16s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)

build: ## 설정을 빌드만 한다 (결과는 ./result)
	nix build .#darwinConfigurations.$(HOST).system

diff: build ## 지금 적용된 시스템과 빌드 결과의 패키지 버전 차이를 보여 준다
	nix store diff-closures /run/current-system ./result

switch: ## 설정을 빌드해서 적용한다 (sudo 필요)
	sudo -H darwin-rebuild switch --flake .#$(HOST)

update-unstable: ## unstable 채널만 갱신한다 (claude-code 등 pkgs.unstable.* 패키지)
	nix flake update nixpkgs-unstable

update: ## 모든 flake input 을 최신으로 갱신한다
	nix flake update

gc: ## 7일보다 오래된 시스템 세대와 사용하지 않는 store 경로를 지운다 (sudo 필요)
	sudo nix-collect-garbage --delete-older-than 7d

fmt: ## nix 파일을 포맷한다 (nixpkgs-fmt)
	nix fmt .

check: ## flake 평가 오류를 검사한다
	nix flake check
