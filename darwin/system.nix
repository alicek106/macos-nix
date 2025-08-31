{ config, pkgs, lib, username, hostname, system, ... }:

{
  # nixpkgs & nix 전역 설정
  nixpkgs.hostPlatform = system;
  nixpkgs.config.allowUnfree = true;

  nix.enable = false;

  # 호스트명
  networking.hostName      = hostname;       # DNS용(일반 HostName)
  networking.computerName  = hostname;       # Finder 등 표시 이름
  networking.localHostName = hostname;       # Bonjour(.local), 하이픈/영문/숫자만

  # 로그인 셸/유저 (시스템 레벨)
  programs.zsh.enable = true;
  users.users.${username} = {
    home  = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Home Manager 연결 (사용자 환경은 별도 파일로)
  home-manager = {
    useGlobalPkgs   = true;
    useUserPackages = true;
    users.${username} = import ../home/alice.nix;
  };

  system.stateVersion = 6;
  system.primaryUser = username;
  time.timeZone = "Asia/Seoul";
}

