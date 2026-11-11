# macOS 시스템 환경설정 (키보드, 트랙패드, Dock, Finder).
# nix-darwin 이 적용(activation) 때 defaults write 로 기록하고, Dock 설정이 있으면 Dock 을 다시 시작한다.
{ ... }:

let
  # Dock 에 고정할 앱 (왼쪽부터). nix 로 설치한 앱은 nix-darwin 이 /Applications/Nix Apps 에 복사해 둔다.
  dockApps = [
    "Visual Studio Code"
    "iTerm2"
    "Slack"
  ];
in
{
  system.defaults = {
    NSGlobalDomain = {
      KeyRepeat = 2;
      InitialKeyRepeat = 15;
      ApplePressAndHoldEnabled = false;
      "com.apple.keyboard.fnState" = false;
      "com.apple.swipescrolldirection" = true;
      "com.apple.trackpad.enableSecondaryClick" = true;
      "com.apple.trackpad.scaling" = 0.9;
      "com.apple.mouse.tapBehavior" = 1; # 탭하여 클릭

      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticInlinePredictionEnabled = false;
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
      persistent-apps = map (name: "/Applications/Nix Apps/${name}.app") dockApps;

      # 화면 네 모서리의 핫 코너 동작을 끈다.
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
}
