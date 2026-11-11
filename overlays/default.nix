# nixpkgs 에 패키지를 추가하거나 덮어쓰는 overlay.
# darwin/default.nix 에서 등록하며, home-manager 도 같은 pkgs 를 쓰므로(useGlobalPkgs) 양쪽에서 pkgs.<이름> 으로 쓸 수 있다.
inputs: final: prev:
let
  # flake.nix 의 nixpkgs-go-1-24-2 input (Go 1.24.2 가 들어 있는 nixpkgs 커밋)
  goPkgs = import inputs.nixpkgs-go-1-24-2 { inherit (prev.stdenv.hostPlatform) system; };
in
{
  go_1_24_2 = goPkgs.go;

  # vendorHash 를 Go 1.24.2 기준으로 계산했으므로 같은 Go 버전으로 빌드한다.
  kubectl-sniff = final.callPackage ../pkgs/kubectl-sniff.nix {
    inherit (goPkgs) buildGoModule;
    src = inputs.ksniff;
  };

  kubectx = final.callPackage ../pkgs/kubectx.nix { };
  inherit (final.callPackage ../pkgs/zip-apps.nix { }) maccy keepingyouawake;
}
