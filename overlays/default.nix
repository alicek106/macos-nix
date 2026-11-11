# nixpkgs 에 overlay 패키지 추가하는 코드. darwin/default.nix에서 사용한다.
# useGlobalPkgs=false 이면 home-manager 가 nixpkgs를 따로 만들어서, overlay 및 allowUnfree를 home/* module에서 사용할 수 없음.
# 하지만 이 값을 true로 설정하면 동일한 pkgs 인스턴스를 사용하므로, darwin/ 과 home/ 모두 pkgs.unstable.<package name>과 pkgs.kubectl-sniff를 사용할 수 있음..!
inputs: final: prev: {
  unstable = import inputs.nixpkgs-unstable {
    inherit (prev.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };

  kubectl-sniff = final.callPackage ../pkgs/kubectl-sniff.nix {
    src = inputs.ksniff;
  };
}
