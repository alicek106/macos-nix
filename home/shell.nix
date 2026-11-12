{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      size = 90000;
      save = 90000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
    };

    shellAliases = {
      pc = "pbcopy";
      pp = "pbpaste";

      gst = "git status";
      gs = "git switch";
      gp = "git pull origin";
    };

    plugins = [
      {
        name = "zsh-expand-all";
        src = pkgs.fetchFromGitHub {
          owner = "simnalamburt";
          repo = "zsh-expand-all";
          rev = "8efea32447ee1e390e7342e304356361a8cd16f2";
          hash = "sha256-dzfNUTm2hcm71TgOjNnJ9ChC9feLnjKk0Fz6hJ4w1UU=";
        };
      }
    ];

    initContent = ''
      stty stop undef
      setopt +o nomatch

      bindkey "^[^[[C" forward-word
      bindkey "^[^[[D" backward-word
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      format = ''
        $kubernetes $directory $git_branch$git_status$aws
        $character
      '';

      right_format = "$time";

      git_branch = {
        format = "[$branch]($style) ";
      };

      git_status = {
        format = "([$ahead_behind$all_status]($style)) ";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        modified = "*";
        staged = "+";
        untracked = "?";
        deleted = "x";
        style = "red bold";
      };

      kubernetes = {
        disabled = false;
        symbol = "☸️ ";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      directory = {
        style = "cyan";
        truncate_to_repo = false;
        truncation_length = 0;
        format = "[$path]($style) ";
      };

      aws = {
        style = "yellow";
        format = ''\[☁️ [$profile]($style)\] '';
      };

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%r";
        style = "bold green";
      };
    };
  };

  programs.fzf.enable = true;

  programs.eza.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config.global.log_filter = "^loading";
  };
}
