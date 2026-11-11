{ ... }:

let
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
      "com.apple.mouse.tapBehavior" = 1;

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
