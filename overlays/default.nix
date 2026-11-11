# nixpkgs 에 패키지를 추가하는 overlay.
# darwin/default.nix 에서 등록하며, home-manager 도 같은 pkgs 를 쓰므로(useGlobalPkgs) 양쪽에서 pkgs.<이름> 으로 쓸 수 있다.
inputs: final: prev: {
  # 최신 버전이 필요한 패키지는 pkgs.unstable.<이름> 으로 가져온다 (예: pkgs.unstable.claude-code).
  # `make update-unstable` 은 이 채널만 갱신하므로, stable 패키지는 그대로 두고 이 패키지들만 올릴 수 있다.
  unstable = import inputs.nixpkgs-unstable {
    inherit (prev.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  kubectl-sniff = final.callPackage ../pkgs/kubectl-sniff.nix {
    src = inputs.ksniff;
  };
}
