{ pkgs, inputs, system, ... }:

let
  appUtils = import ./utils.nix { inherit pkgs; };

  oldGoPkgs = import inputs.pkgs_go_1_24_2 { inherit system; };

  ksniff = oldGoPkgs.buildGoModule {
    pname = "kubectl-sniff";
    version = "0.1.0";
    src = inputs.ksniff;
    vendorHash = "sha256-7pSpOF8UASWqRMWaomoUBA3pD8t0qWiaIcGlXEm0Yx0=";
    subPackages = [ "cmd" ];
    doCheck = false;
    postInstall = ''
      mv $out/bin/cmd $out/bin/kubectl-sniff
    '';
    meta.description = "kubectl-sniff (personal ksniff fork: alicek106/ksniff, privileged-pod mode)";
  };

  kubectx = with pkgs;
    let
      version = "0.11.0";
      fetchBin = name: hash: fetchurl {
        url = "https://github.com/ahmetb/kubectx/releases/download/v${version}/${name}_v${version}_darwin_arm64.tar.gz";
        inherit hash;
      };
      kubectxTar = fetchBin "kubectx" "sha256-uMm1FQym2QJHShFc9+U1gxCBua4Qy+Vh6jbIK7OCPQI=";
      kubensTar = fetchBin "kubens" "sha256-sch93KIvGvw+mArIB6cVzRGDdQAieY0ooKTgz2a+xOM=";
    in
    stdenvNoCC.mkDerivation {
      pname = "kubectx";
      inherit version;
      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        tar -xzf ${kubectxTar} kubectx
        tar -xzf ${kubensTar} kubens
        install -Dm755 kubectx $out/bin/kubectx
        install -Dm755 kubens $out/bin/kubens
        runHook postInstall
      '';
      meta.description = "kubectx/kubens (GitHub release prebuilt, darwin-arm64)";
    };

  cliTools = with pkgs; [
    wireshark
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
    krew
    kubectl-view-secret
    kubernetes-helm
    kubectx
    ksniff
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
    swiftlint
    pprof
    graphviz
    opentofu
    zbar

    # devsisters
    vault
    wireguard-tools
    saml2aws

    # menu bar
    joplin-desktop
    stats
    ice-bar
    rectangle

    # agenix rust implementation
    ragenix

    p4
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
    sarasa-gothic # iTerm Non-ASCII 폰트 후보 (Sarasa Term K)
  ];
}

