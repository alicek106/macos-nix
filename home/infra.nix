# 인프라 업무 도구(kubernetes, terraform, AWS, Vault)의 셸 설정.
# 회사 환경에 맞춘 값(Vault 주소, ECR 계정, 노드 라벨)이 들어 있다.
{ pkgs, ... }:

{
  home.packages = [
    # nixpkgs 의 krew 는 `krew` 라는 이름으로만 설치되어 kubectl 이 플러그인으로 인식하지 못한다.
    # `kubectl krew` 로 쓸 수 있도록 krew 를 가리키는 kubectl-krew 링크를 PATH 에 추가한다.
    (pkgs.runCommand "kubectl-krew" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.krew}/bin/krew $out/bin/kubectl-krew
    '')

    # saml2aws 로 접근 가능한 모든 AWS role 에 로그인해서 awsctx 가 읽는 자격 증명 파일을 만든다.
    (pkgs.writeScriptBin "aws-login-all" (builtins.readFile ./bin/aws-login-all))
  ];

  programs.zsh = {
    sessionVariables = {
      TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
      AWS_SDK_LOAD_CONFIG = "true";
      AWS_PROFILE = "saml";
      KUBE_EDITOR = "vim";

      # 대화형 셸에서는 아래 initContent 의 load_vault_envs 가 프롬프트마다 vaultctx 값으로 덮어쓰므로,
      # 이 값은 프롬프트를 거치지 않는 셸(스크립트 등)에서만 쓰인다.
      VAULT_ADDR = "https://vault.devsisters.cloud";
    };

    shellAliases = {
      # ECR 레지스트리에 docker 로그인
      login = "aws --region ap-northeast-1 ecr get-login-password | docker login --username AWS --password-stdin \"425927401566.dkr.ecr.ap-northeast-1.amazonaws.com\"";

      ks = "kubectl";
      kg = "kubectl get";
      kd = "kubectl describe";
      kn = "kubens";
      ka = "kubectl apply -f";
      kx = "kubectx";
      kvs = "kubectl view-secret";
      kkill = "kubectl delete po --grace-period 0";
      kport = "kubectl port-forward";
      # 노드 목록을 인스턴스 타입, nodepool, capacity type 등의 라벨과 함께 생성 순서대로 보여 준다.
      kgno = "kubectl get nodes -L beta.kubernetes.io/instance-type,aws/instance-group,aws/instance-id,karpenter.sh/nodepool,devsisters.cloud/application,karpenter.sh/capacity-type --sort-by=.metadata.creationTimestamp";

      tws = "terraform workspace select";
      twl = "terraform workspace list";
      tf = "terraform";
    };

    initContent = ''
      # krew 로 설치한 kubectl 플러그인 경로
      export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

      # awsctx: AWS 계정별 설정 파일과 자격 증명 파일을 바꿔 주는 셸 함수. 셸을 열면 infra 계정을 선택한다.
      source ${./script/awsctx.sh}
      awsctx infra

      # vaultctx: Vault 서버를 바꿔 주는 스크립트 (nix 밖에서 ~/.vaultctx 에 설치, README 참고)
      alias vaultctx=~/.vaultctx/script

      function load_vault_envs() {
        export VAULT_ADDR=$(vaultctx get-addr)
      }

      typeset -a precmd_functions
      precmd_functions+=(load_vault_envs)
    '';
  };
}
