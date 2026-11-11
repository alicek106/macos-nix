{
  description = "alicek106 macOS 설정 (M4 MacBook, M1 Mac Studio): nix-darwin + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 미리 만들어 둔 nix-index 데이터베이스 (nix-locate, command-not-found 에서 사용)
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Go 1.24.2 가 들어 있는 nixpkgs 커밋. Go 버전을 고정하려는 input 이므로 nixpkgs 를 follows 하지 않는다.
    nixpkgs-go-1-24-2.url = "github:NixOS/nixpkgs/eaeed9530c76ce5f1d2d8232e08bec5e26f18ec1";

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ksniff 개인 포크의 소스 (flake 가 아닌 일반 저장소)
    ksniff = {
      url = "github:alicek106/ksniff";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, darwin, ... }:
    let
      username = "alicek106";

      # 호스트 이름으로 nix-darwin 시스템 설정을 만든다.
      # 호스트 이름은 flake output 이름이자 macOS 호스트명(darwin/default.nix 의 networking)으로 쓰인다.
      mkDarwin = hostname: darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username hostname; };
        modules = [ ./darwin ];
      };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs [
        "alicek106-m4" # M4 MacBook
        "alicek106-m1" # M1 Mac Studio
      ]
        mkDarwin;

      # `nix fmt` 으로 저장소의 nix 파일을 포맷한다.
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
