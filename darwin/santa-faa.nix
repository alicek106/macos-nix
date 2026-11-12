# santa가 관리하는 file access 관련 rule을 정의하는 nix 코드.
# allowlist에 없는 프로세스가 특정 디렉터리에 접근하면 /var/db/santa/santa.log 에 기록함.
{ config, lib, pkgs, ... }:

let
  home = config.users.users.${config.system.primaryUser}.home;
  appSupport = "${home}/Library/Application Support";

  # profile로 사용될 파일이 존재하는 경로.
  policyPath = "/etc/santa/faa-policy.plist";

  # nix 바이너리는 ad-hoc 서명이라 TeamID 가 없으므로 실행 파일 경로로 지정.
  # 이렇게 하면 nix 업데이트로 인해 경로가 바뀌어도 알아서 갱신됨.
  nixBin = path: { BinaryPath = path; };
  appleBin = id: { SigningID = id; PlatformBinary = true; };
  teamId = id: { TeamID = id; };

  watch = { paths, processes ? [ ] }: {
    Paths = map (p: { Path = p; IsPrefix = true; }) paths;
    Options = {
      RuleType = "PathsWithAllowedProcesses";
      AllowReadAccess = false; # read도 audit 한다.
      AuditOnly = true;
    };
    Processes = processes;
  };

  chromiumProfile = dir: [ "${dir}/*/Cookies" "${dir}/*/Login Data" "${dir}/*/Web Data" "${dir}/Local State" ];

  tofu = "${pkgs.opentofu}/bin/tofu";

  watchItems = {
    SshKeys = watch {
      paths = [ "${home}/.ssh" ];
      processes = map appleBin [ "com.apple.ssh" "com.apple.ssh-add" "com.apple.ssh-agent" "com.apple.ssh-keygen" "com.apple.scp" "com.apple.sftp" ];
    };

    AwsCredentials = watch {
      paths = [ "${home}/.aws" "${home}/Library/Caches/awsctx" ];
      processes = map nixBin [
        "${pkgs.saml2aws}/bin/saml2aws"
        pkgs.awscli2.python.interpreter # awscli는 python wrapper라서 파이썬 스크립트로 간주된다..
        tofu
      ];
    };

    GcloudCredentials = watch {
      paths = [ "${home}/.config/gcloud" ];
      processes = [ (nixBin tofu) ]; # TODO: gcloud CLI도 python wrapper라서 nix에서 그 경로를 참조할 수 있게 바꾸면 좋겠다.
    };

    VaultTokens = watch {
      # vaultctx도 python wrapper이므로 일단은 allowlist에서 제외함.
      # TODO: 같은 python wrapper라도 다르게 allow할 수 있으면 좋겠다.
      paths = [ "${home}/.vaultctx/tokens.json" "${home}/.vault-token" ];
      processes = map nixBin [ "${pkgs.vault}/bin/vault" tofu ];
    };

    KubeConfig = watch {
      paths = [ "${home}/.kube" ];
      processes = map nixBin [
        "${pkgs.kubectl}/bin/kubectl"
        "${pkgs.kubernetes-helm}/bin/helm"
        "${pkgs.kubectx}/bin/kubectx"
        "${pkgs.kubectx}/bin/kubens"
        "${pkgs.kubeseal}/bin/kubeseal"
        "${pkgs.istioctl}/bin/istioctl"
        "${pkgs.stern}/bin/stern"
        "${pkgs.k3d}/bin/k3d"
        "${pkgs.kubectl-view-secret}/bin/kubectl-view_secret"
        "${pkgs.kubectl-sniff}/bin/kubectl-sniff"
        "${pkgs.argo-rollouts}/bin/kubectl-argo-rollouts"
        "${pkgs.cmctl}/bin/cmctl"
        tofu
      ];
    };

    Teleport = watch {
      paths = [ "${home}/.tsh" ];
      processes = [ (nixBin "${pkgs.teleport_17.client}/bin/.tsh-wrapped") ];
    };

    DockerConfig = watch {
      paths = [ "${home}/.docker/config.json" ];
      processes = map nixBin [ "${pkgs.docker}/bin/docker" "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose" ];
    };

    TerraformCloud = watch {
      paths = [ "${home}/.terraform.d/credentials.tfrc.json" ];
      processes = [ (nixBin tofu) ];
    };

    Databricks = watch {
      paths = [ "${home}/.databricks" "${home}/.databrickscfg" ];
      processes = [ (nixBin "${pkgs.unstable.databricks-cli}/bin/databricks") ];
    };

    Perforce = watch {
      paths = [ "${home}/.p4tickets" ];
      processes = [ (nixBin "${lib.getBin pkgs.p4}/bin/p4") ];
    };

    Ngrok = watch {
      paths = [ "${appSupport}/ngrok" ];
      processes = [ (nixBin "${pkgs.ngrok}/bin/ngrok") ];
    };

    Codex = watch {
      paths = [ "${home}/.codex/auth.json" ];
      processes = [ (nixBin "${pkgs.unstable.codex}/bin/codex") ];
      # NOTE: mcp-remote는 node로 실행되어서 일반 node와 구분이 불가능
    };

    Gemini = watch {
      paths = [ "${home}/.gemini/oauth_creds.json" "${home}/.gemini/google_accounts.json" ];
    };

    McpAuth = watch {
      paths = [ "${home}/.mcp-auth" ];
    };

    LoginKeychain = watch {
      paths = [ "${home}/Library/Keychains" ];
      processes = map appleBin [ "com.apple.securityd" "com.apple.secd" ];
    };

    Chrome = watch {
      paths = chromiumProfile "${appSupport}/Google/Chrome";
      processes = [ (teamId "EQHXZ8M8AV") ]; # Google
    };

    Firefox = watch {
      paths = map (f: "${appSupport}/Firefox/Profiles/*/${f}") [ "cookies.sqlite" "logins.json" "key4.db" ];
      processes = [ (teamId "43AQ936H96") ]; # Mozilla
    };

    ShellHistory = watch {
      paths = [ "${home}/.zsh_history" "${home}/.bash_history" "${home}/.psql_history" "${home}/.rediscli_history" ];
      processes = map appleBin [ "com.apple.zsh" "com.apple.bash" ] ++ map nixBin [
        "${pkgs.zsh}/bin/zsh"
        "${pkgs.redis}/bin/redis-cli"
      ];
    };
  };

  policy = {
    Version = builtins.substring 0 8 (builtins.hashString "sha256" (builtins.toJSON watchItems));
    WatchItems = watchItems;
  };

  # santa가 사용할 profile spec
  profile = {
    PayloadType = "Configuration";
    PayloadVersion = 1;
    PayloadScope = "System";
    PayloadIdentifier = "com.alicek106.dotfiles.santa";
    PayloadUUID = "93566013-A9E2-458B-9AD8-51BF10BF7F6E";
    PayloadDisplayName = "Santa (dotfiles)";
    PayloadContent = [{
      PayloadType = "com.northpolesec.santa";
      PayloadVersion = 1;
      PayloadIdentifier = "com.alicek106.dotfiles.santa.config";
      PayloadUUID = "476A944E-BD31-4DE7-BFBD-52EEC6A24ACA";
      PayloadDisplayName = "Santa configuration";
      ClientMode = 1; # Monitor: 실행은 차단하지 않고 기록만
      FileAccessPolicyPlist = policyPath;
      FileAccessPolicyUpdateIntervalSec = 60;
    }];
  };

  toPlist = lib.generators.toPlist { escape = true; };
in
{
  environment.etc."santa/faa-policy.plist".text = toPlist policy;
  environment.etc."santa/santa.mobileconfig".text = toPlist profile;
}
