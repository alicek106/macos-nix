{ config, pkgs, ... }:

let
  user = config.system.primaryUser;
  userHome = config.users.users.${user}.home;
  installedVersion = app:
    let plist = "/Applications/${app}.app/Contents/Info.plist";
    in ''[[ -f "${plist}" ]] && /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${plist}" 2>/dev/null || true'';
in
{
  imports = [ ./santa-faa.nix ];

  system.activationScripts.postActivation.text = ''
    # santa 설치 및 업그레이드
    if [[ "$(${installedVersion "Santa"})" != "${pkgs.santa-pkg.version}" ]]; then
      echo "installing Santa ${pkgs.santa-pkg.version}..." >&2
      /usr/sbin/installer -pkg ${pkgs.santa-pkg} -target / \
        || echo "warning: Santa install failed" >&2
    fi

    # lulu 설치 및 업그레이드
    luluInstalled="$(${installedVersion "LuLu"})"
    if [[ "$luluInstalled" != "${pkgs.lulu.version}" ]]; then
      if [[ -z "$luluInstalled" ]]; then luluAction=-install; else luluAction=-upgrade; fi
      echo "LuLu $luluAction ${pkgs.lulu.version}..." >&2
      ${pkgs.coreutils}/bin/timeout 120 /bin/launchctl asuser "$(/usr/bin/id -u -- ${user})" \
        /usr/bin/env HOME=${userHome} ${pkgs.lulu}/Applications/LuLu.app/Contents/MacOS/LuLu "$luluAction" \
        || echo "warning: LuLu $luluAction failed" >&2
    fi
  '';
}
