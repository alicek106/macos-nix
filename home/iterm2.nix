# iTerm2 설정. 저장소의 plist 를 별도 폴더에 복사하고, iTerm2 가 그 폴더에서 설정을 읽게 한다.
# iTerm2 에서 바꾼 설정을 저장소에 반영하려면 iterm2/plist-sync.sh 를 실행한다 (차이 확인은 plist-diff.sh).
{ config, lib, ... }:

let
  prefsDir = "${config.home.homeDirectory}/.config/iterm2-nix";
in
{
  # home-manager activation 은 사용자 권한으로 실행되므로 defaults 를 바로 쓸 수 있다.
  home.activation.iterm2Prefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run mkdir -p "${prefsDir}"
    run cp -f ${./iterm2/com.googlecode.iterm2.plist} "${prefsDir}/com.googlecode.iterm2.plist" || true

    run /usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${prefsDir}"
    run /usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    # 환경설정 캐시를 비워서 iTerm2 가 다음 실행 때 바뀐 값을 읽게 한다.
    run /usr/bin/killall cfprefsd 2>/dev/null || true
  '';
}
