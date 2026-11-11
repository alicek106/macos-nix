# GitHub 릴리스의 .app zip 파일을 받아 Applications 폴더에 설치하는 macOS 앱
{ stdenv, unzip, fetchurl }:

let
  mkZipApp = { pname, version, src }: stdenv.mkDerivation {
    inherit pname version src;
    nativeBuildInputs = [ unzip ];
    dontUnpack = true;

    # zip 안의 디렉터리 구조와 상관없이 .app 만 찾아 복사한다.
    installPhase = ''
      mkdir -p $out/Applications
      tmpdir=$(mktemp -d)
      unzip -q "$src" -d "$tmpdir"
      find "$tmpdir" -name "*.app" -maxdepth 3 -exec cp -r {} $out/Applications/ \;
    '';
  };
in
{
  maccy = mkZipApp {
    pname = "maccy";
    version = "2.5.0";
    src = fetchurl {
      url = "https://github.com/p0deje/Maccy/releases/download/2.5.0/Maccy.app.zip";
      sha256 = "sha256:b54e9b9e06bc49961b125c1a521487292b7d096e22f9ef4e69d360bad6a8ff10";
    };
  };

  keepingyouawake = mkZipApp {
    pname = "KeepingYouAwake";
    version = "1.6.7";
    src = fetchurl {
      url = "https://github.com/newmarcel/KeepingYouAwake/releases/download/1.6.7/KeepingYouAwake-1.6.7.zip";
      sha256 = "sha256:fd8db2ec536f3fb02607bbc17be1a86b173a9f72331351eb076a63329cc5d915";
    };
  };
}
