{ config, ... }:

{
  imports = [
    ./shell.nix
    ./infra.nix
    ./git.nix
    ./neovim.nix
    ./iterm2.nix
  ];

  # 처음 설치한 시점의 home-manager 버전 값이므로 웬만하면 변경하지 말 것.
  home.stateVersion = "24.05";

  # non-nix로 설치한 바이너리(e.g. tfswitch로 받은 terraform 등)가 위치한 디렉터리
  home.sessionPath = [ "${config.home.homeDirectory}/bin" ];
}
