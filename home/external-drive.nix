# TODO: 설명 주석 추가
{ config, lib, ... }:

let
  work = "/Volumes/Work";
  projectDirs = [ "github" "working" ];
in
{
  home.file = lib.genAttrs projectDirs
    (dir: {
      source = config.lib.file.mkOutOfStoreSymlink "${work}/${dir}";
    }) // {
    ".claude".source = config.lib.file.mkOutOfStoreSymlink "${work}/claude";
  };

  programs.zsh.sessionVariables = {
    TF_PLUGIN_CACHE_DIR = lib.mkForce "${work}/cache/terraform-plugins";
    GOPATH = "${work}/go";
    GOCACHE = "${work}/cache/go-build";
    GOPLSCACHE = "${work}/cache/gopls";
    RUSTUP_HOME = "${work}/rustup";
    CARGO_HOME = "${work}/cargo";
  };

  home.activation.externalDriveDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -d ${work} ]]; then
      run mkdir -p ${lib.concatMapStringsSep " " (dir: "${work}/${dir}") projectDirs} ${work}/cache/terraform-plugins ${work}/claude
    fi
  '';

  # TODO: 설명 주석 추가
  programs.direnv.stdlib = ''
    direnv_layout_dir() {
      local hash dir
      hash=$(printf '%s' "$PWD" | /usr/bin/shasum)
      dir="$HOME/.cache/direnv/layouts/''${hash:0:16}"
      mkdir -p "$dir"
      printf '%s\n' "$PWD" > "$dir/project"
      printf '%s\n' "$dir"
    }
  '';
}
