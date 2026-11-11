# ksniff 개인 포크(alicek106/ksniff)를 kubectl 플러그인으로 빌드한다.
# 포크는 privileged pod 모드를 지원한다.
{ buildGoModule, src }:

buildGoModule {
  pname = "kubectl-sniff";
  version = "0.1.0";
  inherit src;
  vendorHash = "sha256-7pSpOF8UASWqRMWaomoUBA3pD8t0qWiaIcGlXEm0Yx0=";
  subPackages = [ "cmd" ];
  doCheck = false;

  # cmd 패키지를 빌드하면 바이너리 이름이 cmd 가 되므로, kubectl 이 플러그인으로 인식하는 이름으로 바꾼다.
  postInstall = ''
    mv $out/bin/cmd $out/bin/kubectl-sniff
  '';

  meta.description = "kubectl-sniff (personal ksniff fork: alicek106/ksniff, privileged-pod mode)";
}
