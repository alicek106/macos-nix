{
  description = "M4 Macbook Air, M1 Mac Studio Nix Settings";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # command not found 등이 발생했을 때 어느 nix에 있는지 찾아주는 DB
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ksniff = {
      url = "github:alicek106/ksniff";
      flake = false;
    };
  };

  outputs = inputs@{ nixpkgs, nix-darwin, ... }:
    let
      username = "alicek106";

      # hostname을 기반으로 적용할 nix configuration을 고른다.
      # macos 밀고 나서 처음 설치할 때는 make 말고 nix switch로 target 정해서 빌드할 것.
      mkDarwin = hostname: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username hostname; };
        modules = [ ./darwin ];
      };
    in
    {
      darwinConfigurations = nixpkgs.lib.genAttrs [
        "alicek106-m4"
        "alicek106-m1"
      ]
        mkDarwin;

      # nix fmt에서 사용하는 formatter
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    };
}
