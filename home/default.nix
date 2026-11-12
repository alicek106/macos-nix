{ config, ... }:

{
  imports = [
    ./shell.nix
    ./infra.nix
    ./git.nix
    ./neovim.nix
    ./iterm2.nix
    ./package-managers.nix
  ];

  # 처음 설치한 시점의 home-manager 버전 값이므로 웬만하면 변경하지 말 것.
  home.stateVersion = "24.05";
}
