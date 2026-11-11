# nix-darwin 시스템 설정의 시작점. 시스템 기본값을 정하고 나머지 모듈을 불러온다.
{ inputs, username, hostname, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-index-database.darwinModules.nix-index
    ./packages.nix
    ./defaults.nix
  ];

  # nix 데몬과 nix.conf 는 Determinate Nix 설치 프로그램이 관리하므로 nix-darwin 이 건드리지 않게 한다.
  nix.enable = false;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    overlays = [ (import ../overlays inputs) ];
  };

  networking = {
    hostName = hostname; # DNS 호스트명
    computerName = hostname; # Finder 등에 표시되는 이름
    localHostName = hostname; # Bonjour(.local) 이름. 영문, 숫자, 하이픈만 쓸 수 있다.
  };

  time.timeZone = "Asia/Seoul";

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  # /etc/zshenv, /etc/zshrc 에 nix 환경(PATH 등)을 불러오는 설정을 만든다.
  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true; # 시스템과 같은 pkgs(overlay 포함)를 쓴다.
    useUserPackages = true; # home.packages 를 /etc/profiles/per-user/<사용자> 에 설치한다.
    users.${username} = import ../home;
  };

  # 처음 설치한 시점의 nix-darwin 버전 값이므로 바꾸지 않는다.
  system.stateVersion = 6;
}
