{ lib, pkgs, username, hostname, ... }:

let
  swiftlint = pkgs.swiftlint.overrideAttrs (_: {
    version = "0.59.0";
    src = pkgs.fetchurl {
      url = "https://github.com/realm/SwiftLint/releases/download/0.59.0/portable_swiftlint.zip";
      hash = "sha256-rsGt9hy2EklZEA7eQ/Tp9eztVLVlVn9LMPTeZz9fQYA=";
    };
  });

  fastlane = pkgs.writeShellScriptBin "fastlane" ''
    export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
    exec ${pkgs.fastlane}/bin/fastlane "$@"
  '';

  jenkinsUrl = "http://jenkins.alicek106.net/";

  # Fetches agent.jar from the controller on every start so its version always matches.
  jenkinsAgent = pkgs.writeShellScript "jenkins-agent" ''
    set -eu
    export PATH=/etc/profiles/per-user/${username}/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin
    export LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
    work="$HOME/jenkins-agent"
    mkdir -p "$work"
    ${pkgs.curl}/bin/curl -fsSL -o "$work/agent.jar.tmp" ${jenkinsUrl}jnlpJars/agent.jar
    mv "$work/agent.jar.tmp" "$work/agent.jar"
    exec ${pkgs.openjdk21}/bin/java -jar "$work/agent.jar" \
      -url ${jenkinsUrl} \
      -name mac-studio \
      -secret @"$HOME/.config/jenkins-agent/secret" \
      -webSocket \
      -workDir "$work"
  '';
in
lib.mkIf (hostname == "alicek106-m1") {
  services.openssh.enable = true;

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/ZbARmvoy4HkTfYfS7vL/fwp839PWmZ0Sb7BdbsgSN claude-readonly@alicek106-m4"
  ];

  environment.etc."ssh/sshd_config.d/050-tailnet-key-only.conf" = {
    text = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      AllowUsers ${username}@100.64.0.7/32
    '';

    # 원래 손으로 만들었던 파일에 대한 해시값. 지금 한 번만 쓰이고 쓰이지 않는다.
    # 이걸 명시하지 않으면 nix는 자기가 만든 /etc 파일이 아니라고 오류냄
    knownSha256Hashes = [ "e923fb5e9fa96faa68bc2c8326c46833e2aa6dc05c5ad856d0a649d224b41daf" ];
  };

  # Runs in the user's login session; the secret file comes from scripts/mac-studio/jenkins-agent-secret.sh.
  launchd.user.agents.jenkins-agent.serviceConfig = {
    ProgramArguments = [ "${jenkinsAgent}" ];
    RunAtLoad = true;
    KeepAlive = true;
    ThrottleInterval = 30;
    StandardOutPath = "/Users/${username}/Library/Logs/jenkins-agent.log";
    StandardErrorPath = "/Users/${username}/Library/Logs/jenkins-agent.log";
  };

  # hiPrio: wins over swiftlint from apps.nix
  environment.systemPackages = [
    (lib.hiPrio swiftlint)
    fastlane
    pkgs.xcbeautify
  ];
}
