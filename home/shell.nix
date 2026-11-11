# zsh, 프롬프트(starship), 셸에서 쓰는 기본 도구 설정.
# 인프라 업무 도구의 alias 와 초기화 코드는 infra.nix 에 있다.
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
      # 스페이스를 누르면 alias, glob, 하위 명령을 실제 명령줄로 펼쳐 보여 준다.
      # 펼치지 않고 공백만 넣으려면 Ctrl+Space 를 누른다.
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

    # home-manager 옵션으로 지정할 수 없는 설정
    initContent = ''
      # Ctrl+S 를 눌러도 터미널 출력이 멈추지 않게 한다.
      stty stop undef

      # glob 패턴에 맞는 파일이 없으면 오류를 내지 않고 패턴 문자열을 그대로 넘긴다.
      setopt +o nomatch

      # Alt + ←/→ 로 단어 단위 이동
      bindkey "^[^[[C" forward-word
      bindkey "^[^[[D" backward-word
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      # 첫 줄: kubernetes context, 디렉터리, git 상태, AWS 프로필 / 둘째 줄: 입력 위치
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

      # 저장소 기준으로 줄이지 않고 전체 경로를 보여 준다.
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
        time_format = "%r"; # 12시간제 (HH:MM:SS AM/PM)
        style = "bold green";
      };
    };
  };

  programs.fzf.enable = true;

  programs.eza.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
