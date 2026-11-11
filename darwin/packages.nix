# 시스템 전체에 설치하는 패키지와 폰트를 용도별로 나눠 둔다.
# 사용자 셸 설정과 함께 관리하는 도구(git, eza, direnv 등)는 home/ 의 programs.* 가 설치한다.
#
# 패키지 채널 선택 기준:
# - 기본은 stable(nixpkgs 26.05)이며, `make update` 로 전체를 갱신할 때만 버전이 바뀐다.
# - 자주 갱신해야 하는 도구, stable 에 없는 패키지, stable 버전이 너무 낮은 앱만 unstable.<이름> 으로 가져온다.
#   unstable 패키지는 `make update-unstable` 로 따로 갱신할 수 있다.
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
    awscli2
    (google-cloud-sdk.withExtraComponents [ google-cloud-sdk.components.gke-gcloud-auth-plugin ])
    opentofu
    teleport_17 # unstable 에서는 지원 종료로 삭제되어 stable 에만 있다.
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
    # stable 패키지는 바이너리 캐시에 없어서 소스 빌드에 시간과 디스크가 많이 든다 (2026-11 기준).
    unstable.mysql-shell
  ];

  miscTools = with pkgs; [
    unstable.claude-code # 거의 매일 새 버전이 나오므로 unstable 에서 가져온다.
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
    unstable.iterm2 # stable 의 3.6 은 지금 쓰는 3.7 보다 낮다.
    unstable.vscode # stable 패키지(1.144.0)는 빌드가 실패한다 (2026-11 기준).
    slack
    libreoffice-bin
    joplin-desktop
    maccy # 클립보드 기록
    unstable.keepingyouawake # 잠자기 방지 (stable 에 없음)

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
