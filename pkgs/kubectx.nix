# kubectx/kubens 0.11.0 (GitHub 릴리스의 darwin-arm64 바이너리)
{ stdenvNoCC, fetchurl }:

let
  version = "0.11.0";
  fetchBin = name: hash: fetchurl {
    url = "https://github.com/ahmetb/kubectx/releases/download/v${version}/${name}_v${version}_darwin_arm64.tar.gz";
    inherit hash;
  };
  kubectxTar = fetchBin "kubectx" "sha256-uMm1FQym2QJHShFc9+U1gxCBua4Qy+Vh6jbIK7OCPQI=";
  kubensTar = fetchBin "kubens" "sha256-sch93KIvGvw+mArIB6cVzRGDdQAieY0ooKTgz2a+xOM=";
in
stdenvNoCC.mkDerivation {
  pname = "kubectx";
  inherit version;
  dontUnpack = true;
  installPhase = ''
    runHook preInstall
    tar -xzf ${kubectxTar} kubectx
    tar -xzf ${kubensTar} kubens
    install -Dm755 kubectx $out/bin/kubectx
    install -Dm755 kubens $out/bin/kubens
    runHook postInstall
  '';
  meta.description = "kubectx/kubens (GitHub release prebuilt, darwin-arm64)";
}
