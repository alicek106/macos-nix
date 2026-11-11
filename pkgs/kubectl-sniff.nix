{ buildGoModule, src }:

buildGoModule {
  pname = "kubectl-sniff";
  version = "0.1.0";
  inherit src;
  vendorHash = "sha256-7pSpOF8UASWqRMWaomoUBA3pD8t0qWiaIcGlXEm0Yx0=";
  subPackages = [ "cmd" ];
  doCheck = false;
  postInstall = ''
    mv $out/bin/cmd $out/bin/kubectl-sniff
  '';

  meta.description = "kubectl-sniff (personal ksniff fork: alicek106/ksniff, privileged-pod mode)";
}
