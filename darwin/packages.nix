# 시스템 전체에 설치하는 패키지와 폰트를 용도별로 나눠 둔다.
# 사용자 셸 설정과 함께 관리하는 도구(git, eza, direnv 등)는 home/ 의 programs.* 가 설치한다.
{ pkgs, inputs, ... }:

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
    nil # nix 언어 서버
  ];

  devTools = with pkgs; [
    go_1_24_2 # overlays/default.nix 에서 고정한 버전
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
  ];

  cloudTools = with pkgs; [
    awscli
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    opentofu
    teleport_17
    docker
    docker-compose
    ragenix # agenix 의 rust 구현

    # 회사 업무용
    vault
    wireguard-tools
    saml2aws
  ];

  networkTools = with pkgs; [
    wireshark
    grpcui
    grpcurl
    stuntman
    ngrok
    jwt-cli
  ];

  databaseTools = with pkgs; [
    redis
    postgresql_17_jit
    mysql84
    mysql-shell
  ];

  miscTools = with pkgs; [
    inputs.claude-code.packages.${stdenv.hostPlatform.system}.default
    gh
    ffmpeg
    zbar
    p4
    virt-viewer
    terminal-notifier
  ];

  # nix-darwin 이 /Applications/Nix Apps 에 복사해 둔다.
  # Google Chrome 은 nix 로 설치하면 Enpass 확장이 동작하지 않아 직접 설치한다 (README 참고).
  guiApps = with pkgs; [
    iterm2
    vscode
    slack
    libreoffice-bin
    joplin-desktop
    maccy
    keepingyouawake

    # 메뉴 막대
    stats
    ice-bar
    rectangle
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
    nerd-fonts.jetbrains-mono # neovim 상태 막대와 아이콘 글리프 (iTerm2 폰트로 지정해야 함)
    d2coding
    sarasa-gothic # iTerm2 의 Non-ASCII 폰트 후보 (Sarasa Term K)
    nanum-gothic-coding # iTerm2 의 Non-ASCII(한글) 폰트
  ];
}
