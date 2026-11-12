{ ... }:

{
  # npm i -g 시, prefix를 home으로 지정해서 nix store의 nodejs 경로에 파일을 못만들게 하기 위함
  # NOTE: 애초에 -g는 못하게 막으면 좋을듯?
  home.file.".npmrc".text = ''
    ignore-scripts=true
    min-release-age=7
    prefix=''${HOME}/.npm-global
  '';

  xdg.configFile."uv/uv.toml".text = ''
    exclude-newer = "7 days"
  '';
}
