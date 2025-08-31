# darwin/app-utils.nix
{ pkgs }:

{ pname, version, src }:
pkgs.stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [ pkgs.unzip ];
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/Applications
    tmpdir=$(mktemp -d)
    unzip -q "$src" -d "$tmpdir"
    # 어떤 디렉토리 구조든 .app만 찾아서 Applications에 복사
    find "$tmpdir" -name "*.app" -maxdepth 3 -exec cp -r {} $out/Applications/ \;
  '';
}
