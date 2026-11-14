{ inputs, pkgs, ... }:

{
  home.packages = [
    inputs.keycloak2aws.packages.${pkgs.stdenv.hostPlatform.system}.kc2aws
  ];

  home.sessionPath = [ "$HOME/.tfswitch" ];

  programs.zsh = {
    sessionVariables = {
      TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
      AWS_SDK_LOAD_CONFIG = "true";
      AWS_PROFILE = "saml";
      KUBE_EDITOR = "vim";

      TF_INSTALL_PATH = "$HOME/.tfswitch";
      TF_BINARY_PATH = "$HOME/.tfswitch/terraform";

      # vaultctx에서는 이 값을 사용하지 않음. terraform 등 바이너리에서 사용하기 위한 기본 값.
      VAULT_ADDR = "https://vault.devsisters.cloud";
    };

    shellAliases = {
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
      kgno = "kubectl get nodes -L beta.kubernetes.io/instance-type,aws/instance-group,aws/instance-id,karpenter.sh/nodepool,devsisters.cloud/application,karpenter.sh/capacity-type --sort-by=.metadata.creationTimestamp";

      tws = "terraform workspace select";
      twl = "terraform workspace list";
      tf = "terraform";
    };

    initContent = ''
      source ${./script/awsctx.sh}
      awsctx infra

      alias vaultctx=~/.vaultctx/script

      function load_vault_envs() {
        export VAULT_ADDR=$(vaultctx get-addr)
      }

      typeset -a precmd_functions
      precmd_functions+=(load_vault_envs)
    '';
  };
}
