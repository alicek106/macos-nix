{ pkgs, lib, username, hostname, ... }:

# Solitaire: Decked Out 로컬 개발 환경 (M1 Mac Studio 전용)
# - Claude Code 자율 작업용 sudo 래퍼: 비밀번호 없이 root 실행이 가능한 유일한 대상.
#   실행 전에 Slack 웹훅으로 명령을 먼저 알리고(실패 시 실행 거부 = fail-closed)
#   /var/log/claude-asudo.log 에 기록한다.
# - 운영 문서/기록: ~/working/solitaire-project (CLAUDE.md, docs/)
# - 되돌리기: flake.nix modules 에서 이 파일을 빼고 darwin-rebuild switch.
let
  webhookFile = "/Users/${username}/.config/solitaire-ops/slack-webhook";

  claudeAsudoExec = pkgs.writeShellScriptBin "claude-asudo-exec" ''
    set -u
    export PATH="/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    export HOME=/var/root
    LOG=/var/log/claude-asudo.log

    if [ "$#" -eq 0 ]; then
      echo "usage: asudo <command> [args...]" >&2
      exit 64
    fi

    ts="$(date '+%F %T %Z')"
    caller="''${SUDO_USER:-unknown}"
    cwd="$(pwd)"
    cmdline="$(printf '%q ' "$@")"
    printf '%s START user=%s cwd=%s cmd=%s\n' "$ts" "$caller" "$cwd" "$cmdline" >> "$LOG"

    url="$(cat ${webhookFile} 2>/dev/null || true)"
    if [ -z "$url" ]; then
      printf '%s REFUSED no-webhook cmd=%s\n' "$ts" "$cmdline" >> "$LOG"
      echo "claude-asudo: webhook file missing (${webhookFile}); refusing to run without notification" >&2
      exit 70
    fi

    text="$(printf '*[solitaire-ops] :closed_lock_with_key: sudo 실행* (%s, %s)\n사용자: %s\n위치: %s\n명령: `%s`' \
      "$(hostname -s)" "$ts" "$caller" "$cwd" "$cmdline")"
    payload="$(${pkgs.jq}/bin/jq -n --arg t "$text" '{text: $t}')"
    if ! ${pkgs.curl}/bin/curl -fsS -m 15 -X POST -H 'Content-Type: application/json' \
         --data "$payload" "$url" >/dev/null; then
      printf '%s REFUSED notify-failed cmd=%s\n' "$ts" "$cmdline" >> "$LOG"
      echo "claude-asudo: Slack notification failed; refusing to run (fail-closed)" >&2
      exit 75
    fi

    "$@"
    rc=$?
    printf '%s END rc=%s cmd=%s\n' "$(date '+%F %T %Z')" "$rc" "$cmdline" >> "$LOG"
    exit "$rc"
  '';
in
lib.mkIf (hostname == "alicek106-m1") {
  environment.systemPackages = [
    claudeAsudoExec

    # Unity iOS 빌드 체인
    pkgs.git-lfs # SolitaireX: *.so, *.bundle 이 LFS
    pkgs.cocoapods # Unity iOS export 후 pod install
    pkgs.xcbeautify # xcodebuild 로그 정리
  ];

  # nixpkgs 의 unityhub 는 Linux 전용이라 Unity Hub 만 brew cask 로 선언한다.
  # /opt/homebrew 에 손으로 설치한 formula 들이 있으므로 cleanup 은 반드시 "none".
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
    };
    casks = [ "unity-hub" ];
  };

  # git lfs install 을 손으로 하면 ~/.gitconfig 가 바뀌므로 home-manager 로 선언한다.
  home-manager.users.${username}.programs.git.lfs.enable = true;

  # 래퍼의 정확한 /nix/store 경로만 NOPASSWD. 일반 sudo 는 계속 비밀번호를 요구한다.
  security.sudo.extraConfig = ''
    ${username} ALL=(root) NOPASSWD: ${claudeAsudoExec}/bin/claude-asudo-exec
  '';
}
