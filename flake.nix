{
  description = "Fully declarative macOS (M4 MacBook, M1 Mac Studio): apps + Dock + defaults + dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    # 옛 Go 버전(1.24.2) 고정용 nixpkgs (follows 하면 안 됨)
    pkgs_go_1_24_2.url = "github:NixOS/nixpkgs/eaeed9530c76ce5f1d2d8232e08bec5e26f18ec1";

    claude-code.url = "github:sadjow/claude-code-nix";
    claude-code.inputs.nixpkgs.follows = "nixpkgs";

    ksniff.url = "github:alicek106/ksniff";
    ksniff.flake = false;
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, nix-index-database, ... }:
    let
      system = "aarch64-darwin"; # Apple Silicon
      username = "alicek106"; # 단일 사용자명

      mkDarwin = hostname: darwin.lib.darwinSystem {
        inherit system;

        # 모듈 공통 인자(필요 시 사용)
        specialArgs = { inherit system username hostname inputs; };

        modules = [
          # Home Manager를 nix-darwin에 통합
          home-manager.darwinModules.home-manager

          # 시스템 레벨 모듈
          ./darwin/system.nix
          ./darwin/apps.nix
          ./darwin/defaults.nix
          ./darwin/solitaire-dev.nix # M1 Mac Studio 전용 (모듈 내부 hostname 조건)
          ./darwin/ios-build.nix # M1 only

          # nix-index 데이터베이스 모듈
          nix-index-database.darwinModules.nix-index
        ];
      };
    in
    {
      # 키 = 호스트명 (networking.hostName 등에 그대로 들어감)
      darwinConfigurations = {
        "alicek106-m4" = mkDarwin "alicek106-m4"; # M4 MacBook
        "alicek106-m1" = mkDarwin "alicek106-m1"; # M1 Mac Studio
      };

      # devShell: 고정 버전의 kubectl/terraform/curl을 즉시 사용
      devShells.${system}.default =
        let pkgs = import nixpkgs { inherit system; };
        in pkgs.mkShell {
          packages = with pkgs; [ kubectl terraform curl jq ];
          shellHook = ''
            echo "[devShell] kubectl=$(kubectl version --client --short 2>/dev/null || true)"
            echo "[devShell] terraform=$(terraform version 2>/dev/null | head -1 || true)"
          '';
        };
    };
}

