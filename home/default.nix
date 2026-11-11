# home-manager 사용자 설정의 시작점. 주제별 파일을 불러온다.
# home.username 과 home.homeDirectory 는 nix-darwin 의 users.users 값으로 자동 설정된다.
{ config, ... }:

{
  imports = [
    ./shell.nix
    ./infra.nix
    ./git.nix
    ./neovim.nix
    ./iterm2.nix
  ];

  # 처음 설치한 시점의 home-manager 버전 값이므로 바꾸지 않는다.
  home.stateVersion = "24.05";

  # nix 밖에서 받은 바이너리(tfswitch 로 받은 terraform 등)를 두는 디렉터리
  home.sessionPath = [ "${config.home.homeDirectory}/bin" ];
}
