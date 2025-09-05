{ config, pkgs, lib, username, ... }:

let
  # Nix 앱 링크를 만들 위치
  userApps = "/Users/${username}/Applications/Nix Apps";

  # 관리할 앱 목록 (여기 한 줄씩만 추가하면 symlink + Dock 자동 반영)
  nixApps = [
    { pkg = pkgs.iterm2;         app = "iTerm2.app"; }
    { pkg = pkgs.vscode;         app = "Visual Studio Code.app"; }
    { pkg = pkgs.slack;          app = "Slack.app"; }
    { pkg = pkgs.google-chrome;  app = "Google Chrome.app"; }
    { pkg = pkgs.jetbrains.goland;  app = "GoLand.app"; }
    # { pkg = pkgs.firefox;      app = "Firefox.app"; }  # 예: 추가하고 싶으면 이렇게
  ];

  # Dock persistent-apps 경로 리스트
  dockApps = map (a: "${userApps}/${a.app}") nixApps;

  # symlink 생성 스크립트
  mkLinks = lib.concatStringsSep "\n" (
    map (a: ''
      ln -sfn "${a.pkg}/Applications/${a.app}" "${userApps}/${a.app}"
    '') nixApps
  );
in {
  # macOS 기본 설정 (키보드, 트랙패드, Dock, Finder 등)
  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      "com.apple.keyboard.fnState" = false;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.scaling" = 0.9;
      "com.apple.mouse.tapBehavior" = 1;

      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled     = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled  = false;
      NSAutomaticDashSubstitutionEnabled   = false;
      NSAutomaticInlinePredictionEnabled   = false;
    };

    trackpad = {
      Clicking = true;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = false;
      ActuationStrength = 0;
      FirstClickThreshold = 0;
      SecondClickThreshold = 0;
    };

    dock = {
      autohide = false;
      magnification = false;
      tilesize = 60;
      orientation = "bottom";
      show-recents = false;
      persistent-apps = dockApps;
      wvous-tl-corner = 1;
      wvous-tr-corner = 1;
      wvous-bl-corner = 1;
      wvous-br-corner = 1;
    };

    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };
  };

  # postActivation 스크립트
  system.activationScripts.postActivation.text = ''
    ## Nix Apps 링크 보장
    mkdir -p "${userApps}"
    ${mkLinks}

    ## 트랙패드 관련 (사용자 세션에서 preferences 설정)
    user="${username}"
    uid="$(/usr/bin/id -u "$user")"

    /bin/launchctl asuser "$uid" /usr/bin/defaults write -g com.apple.mouse.tapBehavior -int 1
    /bin/launchctl asuser "$uid" /usr/bin/defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1

    /bin/launchctl asuser "$uid" /usr/bin/defaults write com.apple.AppleMultitouchTrackpad Clicking -int 1
    /bin/launchctl asuser "$uid" /usr/bin/defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    /bin/launchctl asuser "$uid" /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -int 1 2>/dev/null || true
    /bin/launchctl asuser "$uid" /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true 2>/dev/null || true

    /bin/launchctl asuser "$uid" /usr/bin/killall cfprefsd 2>/dev/null || true
    /bin/launchctl asuser "$uid" /usr/bin/killall SystemUIServer 2>/dev/null || true

    /usr/bin/killall Dock 2>/dev/null || true
    /usr/bin/killall Finder 2>/dev/null || true
  '';
}

