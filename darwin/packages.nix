# global로 설치하는 패키지 및 폰트
# shell 연동 혹은 설정파일이 별도로 필요한 패키지는 home/ 밑에서 관리함 (e.g. git 등)
# 만약 아래 도구들 중, 버전 업데이트가 필요한 것이 있다면 unstable pkgs로 옮겨가서 쓸 것.
{ pkgs, ... }:

let
  baseTools = with pkgs; [
    coreutils-full
    findutils
    gawk
    gnused
    ripgrep
    fd
    bat
    tree
    jq
    wget
    curl
    unzip
    gnupg
    watch
    htop
  ];

  nixTools = with pkgs; [
    nixpkgs-fmt
    nil # nix 언어 서버...
  ];

  devTools = with pkgs; [
    go
    openjdk21
    nodejs_24
    python312
    python312Packages.pip
    uv
    rust-analyzer
    golangci-lint
    swiftlint
    pkgconf
    openssl
    pprof
    graphviz
    jwt-cli
    gopls
    go-tools # staticcheck
    rustup
    sqlx-cli
    mdbook
    ast-grep
    poetry
  ];

  kubernetesTools = with pkgs; [
    kubectl
    krew
    kubectl-view-secret
    kubectl-sniff # pkgs/kubectl-sniff.nix
    kubernetes-helm
    kubectx
    kubeseal
    istioctl
    stern
    k3d
    argo-rollouts # kubectl-argo-rollouts
    cmctl # cert-manager
    kubectl-node-shell
  ];

  cloudTools = with pkgs; [
    awscli2
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    opentofu
    tfswitch
    teleport_17 # 참고: unstable에는 더이상 없음....
    docker
    docker-compose
    ragenix
    vault
    saml2aws
    unstable.databricks-cli
    ssm-session-manager-plugin
  ];

  networkTools = with pkgs; [
    wireshark
    grpcui
    grpcurl
    stuntman
    ngrok
    wireguard-tools
  ];

  databaseTools = with pkgs; [
    redis
    postgresql_17_jit
    mysql84
    unstable.mysql-shell
  ];

  miscTools = with pkgs; [
    unstable.claude-code
    unstable.codex
    gh
    ffmpeg
    zbar
    p4
    virt-viewer
    terminal-notifier
  ];

  # 참고: Google Chrome 은 nix 로 설치하면 Enpass 확장이 동작하지 않아 직접 설치해야 함...
  guiApps = with pkgs; [
    unstable.iterm2
    unstable.vscode
    unstable.keepingyouawake
    slack
    libreoffice-bin
    maccy
    stats
    ice-bar
    thaw # overlays/default.nix 에서 2.1.0 으로 override
    rectangle
    dbeaver-bin
    discord
    unstable.raycast
    vlc-bin
    unstable.p4v
    prismlauncher
  ];
in
{
  environment.systemPackages =
    baseTools
    ++ nixTools
    ++ devTools
    ++ kubernetesTools
    ++ cloudTools
    ++ networkTools
    ++ databaseTools
    ++ miscTools
    ++ guiApps;

  fonts.packages = with pkgs; [
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    d2coding
    sarasa-gothic
    nanum-gothic-coding
  ];
}
