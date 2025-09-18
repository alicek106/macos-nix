{ config, pkgs, lib, inputs, system, ... }:

let
  appUtils = import ./utils.nix { inherit pkgs; };

  oldGoPkgs = import inputs.pkgs_go_1_24_2 { inherit system; };

  cliTools = with pkgs; [
    # basics
    git jq ripgrep fd bat eza tree wget unzip gnupg
    coreutils-full findutils gawk gnused
    direnv nix-direnv nix-index nixpkgs-fmt nil watch 

    # dev-tools 
    openjdk21 curl kubectl terraform
    colima docker docker-compose awscli kubectx
    claude-code htop redis golangci-lint

    # devsisters
    vault wireguard-tools saml2aws

    # manu bar
    joplin-desktop stats ice-bar rectangle
  ];

  guiApps = with pkgs; [
    iterm2
    vscode
    slack
    google-chrome
    jetbrains.goland
    libreoffice-bin
  ];

  maccy = appUtils {
    pname = "maccy";
    version = "2.5.0";
    src = pkgs.fetchurl {
      url = "https://github.com/p0deje/Maccy/releases/download/2.5.0/Maccy.app.zip";
      sha256 = "sha256:b54e9b9e06bc49961b125c1a521487292b7d096e22f9ef4e69d360bad6a8ff10";
    };
  };

  keepingYouAwake = appUtils {
    pname = "KeepingYouAwake";
    version = "1.6.7";
    src = pkgs.fetchurl {
      url = "https://github.com/newmarcel/KeepingYouAwake/releases/download/1.6.7/KeepingYouAwake-1.6.7.zip";
      sha256 = "sha256:fd8db2ec536f3fb02607bbc17be1a86b173a9f72331351eb076a63329cc5d915";
    };
  };

  customApps = [
    maccy
    keepingYouAwake
  ];

  languages = {
    go = [
      oldGoPkgs.go
    ];
  };

in {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    cliTools
    ++ guiApps
    ++ customApps
    ++ [ oldGoPkgs.go ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    d2coding
  ];
}

