{ pkgs, username, hostname, system, ... }:

{
  # NOTE: tailscale은 Mac App 혹은 웹페이지에서 내려받읍시다..

  # nixpkgs & nix 전역 설정
  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  nix.enable = false;

  # 호스트명
  networking.hostName = hostname; # DNS용(일반 HostName)
  networking.computerName = hostname; # Finder 등 표시 이름
  networking.localHostName = hostname; # Bonjour(.local), 하이픈/영문/숫자만

  # 로그인 셸/유저 (시스템 레벨)
  programs.zsh.enable = true;
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Home Manager 연결 (사용자 환경은 별도 파일로)
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    # HM이 관리할 파일이 이미 존재하면 .backup 으로 옮기고 진행
    # (없으면 activation이 중단되어 /run/current-system 이 갱신되지 않음)
    backupFileExtension = "backup";
    users.${username} = import ../home/alice.nix;
  };

  system.stateVersion = 6;
  system.primaryUser = username;
  time.timeZone = "Asia/Seoul";
}

