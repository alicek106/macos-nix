# iTerm2 에서 변경한 설정을 저장소에 반영하려면 iterm2/plist-sync.sh 를, drift 확인은 plist-diff.sh 실행
{ config, lib, ... }:

let
  prefsDir = "${config.home.homeDirectory}/.config/iterm2-nix";
in
{
  home.activation.iterm2Prefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${prefsDir}"
    run cp -f ${./iterm2/com.googlecode.iterm2.plist} "${prefsDir}/com.googlecode.iterm2.plist" || true

    run /usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${prefsDir}"
    run /usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    # 환경설정 캐시를 리셋해서 iTerm2를 다시 실행할 때 수정된 설정을 리로드하도록 만든다.
    run /usr/bin/killall cfprefsd 2>/dev/null || true
  '';
}
