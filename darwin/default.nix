{ lib, inputs, username, hostname, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    inputs.nix-index-database.darwinModules.nix-index
    ./packages.nix
    ./defaults.nix
  ]
  # Santa, LuLu 는 일단 맥북에서만 우선 써보고 괜찮으면 맥스튜디오에도 적용할 예정
  ++ lib.optional (hostname == "alicek106-m4") ./security.nix;

  # nix 데몬과 nix.conf 는 Determinate Nix가 관리하므로 nix-darwin에서는 비활성화
  nix.enable = false;

  nixpkgs = {
    hostPlatform = "aarch64-darwin";
    config.allowUnfree = true;
    overlays = [ (import ../overlays inputs) ];
  };

  networking = {
    hostName = hostname; # DNS 호스트명
    computerName = hostname; # Finder 등에 표시되는 이름
    localHostName = hostname; # Bonjour link local 이름
  };

  time.timeZone = "Asia/Seoul";

  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";

  programs.zsh.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true; # home.packages 를 /etc/profiles/per-user/<username> 에 설치하는 설정
    users.${username} = import ../home;
  };

  # 처음 설치한 시점의 nix-darwin 버전 값. 웬만하면 변경하지 말것.
  system.stateVersion = 6;
}
