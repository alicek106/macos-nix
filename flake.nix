{
  description = "alicek106 macOS 설정 (M4 MacBook, M1 Mac Studio): nix-darwin + home-manager";

  inputs = {
    # 기본 패키지 채널 (stable). nix-darwin, home-manager 도 같은 릴리스 브랜치를 쓴다.
    # 릴리스를 올릴 때는 아래 세 줄의 26.05 를 함께 바꾼다.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 최신 버전이 필요한 패키지에만 쓰는 채널. overlays/default.nix 에서 pkgs.unstable 로 노출한다.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # 미리 만들어 둔 nix-index 데이터베이스 (nix-locate, command-not-found 에서 사용)
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ksniff 개인 포크의 소스 (flake 가 아닌 일반 저장소)
    ksniff = {
      url = "github:alicek106/ksniff";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, ... }:
    let
      username = "alicek106";

      # 호스트 이름으로 nix-darwin 시스템 설정을 만든다.
      # 호스트 이름은 flake output 이름이자 macOS 호스트명(darwin/default.nix 의 networking)으로 쓰인다.
      mkDarwin = hostname: nix-darwin.lib.darwinSystem {
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
