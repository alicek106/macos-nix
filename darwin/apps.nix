{ pkgs, inputs, system, ... }:

let
  appUtils = import ./utils.nix { inherit pkgs; };

  oldGoPkgs = import inputs.pkgs_go_1_24_2 { inherit system; };

  cliTools = with pkgs; [
    # basics
    git
    jq
    ripgrep
    fd
    bat
    eza
    tree
    wget
    unzip
    gnupg
    coreutils-full
    findutils
    gawk
    gnused
    nix-direnv
    nix-index
    nixpkgs-fmt
    nil
    watch

    # dev-tools
    openjdk21
    curl
    kubectl
    kubectl-view-secret
    kubernetes-helm
    kubectx
    docker
    docker-compose
    awscli
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    htop
    redis
    golangci-lint
    uv
    grpcui
    grpcurl
    tailscale
    stuntman
    istioctl
    postgresql_17_jit
    ffmpeg
    ngrok
    jwt-cli
    teleport_17
    kubeseal
    nodejs_24
    codex
    terminal-notifier
    python312
    python312Packages.pip
    pkgconf
    openssl
    rust-analyzer
    mysql-shell
    k3d
    gh
    inputs.claude-code.packages.${system}.default

    # devsisters
    vault
    wireguard-tools
    saml2aws

    # menu bar
    joplin-desktop
    stats
    ice-bar
    rectangle
  ];

  guiApps = with pkgs; [
    iterm2
    vscode
    slack
    # google-chrome # chrome은 enpass 플러그인 의존성으로 인해 직접 설치
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

in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    cliTools
    ++ guiApps
    ++ customApps
    ++ [ oldGoPkgs.go ];

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono # neovim 상태바/아이콘용 글리프 (iTerm 폰트로 지정 필요)
    d2coding
  ];
}

