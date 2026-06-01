{ config, pkgs, lib, ... }:

let
  itermCustomDir = "${config.home.homeDirectory}/.config/iterm2-nix"; # iTerm2가 읽을 폴더
  srcPlist = ./iterm2/com.googlecode.iterm2.plist; # 기존 맥에서 복사

  # nvim 디버깅용 codelldb (rustaceanvim 의 dap 어댑터로 사용)
  codelldb = pkgs.vscode-extensions.vadimcn.vscode-lldb;
  codelldbDir = "${codelldb}/share/vscode/extensions/vadimcn.vscode-lldb";

  # nix store 경로를 lua 로 노출 (rust.lua 가 require("nix_paths") 로 읽음)
  nvimNixPaths = ''
    return {
      codelldb = "${codelldbDir}/adapter/codelldb",
      liblldb = "${codelldbDir}/lldb/lib/liblldb.dylib",
    }
  '';
in
{
  home.username = "alicek106";
  home.homeDirectory = "/Users/alicek106";
  home.stateVersion = "24.05";

  # nixpkgs krew는 `krew` 이름으로만 설치돼 kubectl이 플러그인으로 인식 못 함.
  # `kubectl krew` 로 쓰기 위해 nix krew를 가리키는 kubectl-krew 심볼릭 링크를 PATH에 노출.
  home.packages = [
    (pkgs.runCommand "kubectl-krew" { } ''
      mkdir -p $out/bin
      ln -s ${pkgs.krew}/bin/krew $out/bin/kubectl-krew
    '')
  ];

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # 히스토리 설정
    history = {
      size = 90000;
      save = 90000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true; # histignoredups
    };

    # 환경 변수
    sessionVariables = {
      TF_PLUGIN_CACHE_DIR = "$HOME/.terraform.d/plugin-cache";
      VAULT_ADDR = "https://vault.devsisters.cloud";
      AWS_SDK_LOAD_CONFIG = "true";
      AWS_PROFILE = "saml";
      KUBE_EDITOR = "vim";
    };

    # alias 모음
    shellAliases = {
      pc = "pbcopy";
      pp = "pbpaste";
      login = "aws --region ap-northeast-1 ecr get-login-password | docker login --username AWS --password-stdin \"425927401566.dkr.ecr.ap-northeast-1.amazonaws.com\"";

      # kubectl
      ks = "kubectl";
      kg = "kubectl get";
      kd = "kubectl describe";
      kn = "kubens";
      ka = "kubectl apply -f";
      kx = "kubectx";
      kvs = "kubectl view-secret";
      kkill = "kubectl delete po --grace-period 0";
      kport = "kubectl port-forward";
      kgno = "kubectl get nodes -L beta.kubernetes.io/instance-type,aws/instance-group,aws/instance-id,karpenter.sh/nodepool,devsisters.cloud/application,karpenter.sh/capacity-type --sort-by=.metadata.creationTimestamp";

      # terraform
      tws = "terraform workspace select";
      twl = "terraform workspace list";
      tf = "terraform";

      # git
      gst = "git status";
      gs = "git switch";
      gp = "git pull origin";
    };

    # 직접 지원하지 않는 옵션들만 initExtra에 작성
    initContent = ''
      # Ctrl+S (터미널 freeze) 끄기
      stty stop undef

      # zsh globbing 오류 무시
      setopt +o nomatch

      # krew (kubectl 플러그인) PATH 추가 - kubectl-sniff 등 ~/.krew/bin 의 플러그인 실행용
      export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

      # 프롬프트 오른쪽에 시간 출력
      RPROMPT="[%D{%H:%M:%S}]"

      # Alt + ←/→ 로 단어 단위 이동
      bindkey "^[^[[C" forward-word
      bindkey "^[^[[D" backward-word

      # starship
      eval "$(${pkgs.starship}/bin/starship init zsh)"

      # zinit으로만 설치 가능한 플러그인들
      if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
        git clone https://github.com/zdharma-continuum/zinit.git \
          "$HOME/.local/share/zinit/zinit.git"
      fi
      source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
      zinit light simnalamburt/zsh-expand-all

      source ~/dotfiles/home/script/awsctx.sh
      awsctx infra

      alias vaultctx=~/.vaultctx/script
      
      function load_vault_envs() {
        export VAULT_ADDR=$(vaultctx get-addr)
      }
      
      typeset -a precmd_functions
      precmd_functions+=(load_vault_envs)
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      # 전체 포맷 정의
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
        ahead = "⇡"; # 원격보다 커밋이 앞설 때
        behind = "⇣"; # 원격보다 뒤쳐졌을 때
        diverged = "⇕";
        modified = "*"; # 수정사항 있으면 빨간 별만
        staged = "+"; # staged 변경사항
        untracked = "?";
        deleted = "x";
        style = "red bold";
      };

      # Kubernetes 모듈
      kubernetes = {
        disabled = false;
        symbol = "☸️ ";
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };

      # 디렉토리 전체 경로
      directory = {
        style = "cyan";
        truncate_to_repo = false;
        truncation_length = 0; # 풀 경로
        format = "[$path]($style) ";
      };

      # AWS 프로파일
      aws = {
        style = "yellow";
        format = ''\[☁️ [$profile]($style)\] '';
      };

      time = {
        disabled = false;
        format = "[$time]($style) ";
        time_format = "%r"; # 12시간제 HH:MM:SS AM/PM
        style = "bold green";
      };

      cmd_duration = {
        min_time = 500; # 0.5초 이상만 표시
        format = "took [$duration]($style) ";
        style = "bold red";
        show_milliseconds = true;
      };
    };
  };

  programs.fzf.enable = true;

  programs.git = {
    enable = true;
    userName = "alicek106"; # 필요시 수정
    userEmail = "alice_k106@naver.com"; # 필요시 수정
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
      core.editor = "vim";
    };
    ignores = [ ".DS_Store" ".direnv" "result" ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;

    # 플러그인: vim-plug → nixpkgs.vimPlugins
    plugins = with pkgs.vimPlugins; [
      # 기존 구성
      typescript-vim
      nerdtree
      vim-mundo
      vim-terraform
      vim-lastplace
      vim-sensible
      vim-yaml
      fzf-vim
      vim-jsonnet
      vim-go
      vim-helm
      nvim-scrollbar

      # UI 현대화
      lualine-nvim # 상태바 (vim-airline 대체)
      nvim-web-devicons
      tokyonight-nvim # 다크 테마
      gitsigns-nvim # git 거터
      nvim-autopairs
      indent-blankline-nvim
      nvim-ufo # 코드 접기(folding) UI
      promise-async # nvim-ufo 의존성
      (nvim-treesitter.withPlugins (p: with p; [
        rust
        toml
        lua
        json
        yaml
        bash
        markdown
        markdown_inline
        vimdoc
      ]))

      # Rust LSP / 자동완성
      rustaceanvim
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      friendly-snippets

      # 탐색 / 의존성 / 디버깅
      telescope-nvim
      plenary-nvim
      crates-nvim
      nvim-dap
      nvim-dap-ui
      nvim-nio
    ];

    extraLuaConfig = ''
      require("scrollbar").setup()
      require("ui")
      require("rust")
    '';

    extraConfig = ''
      " === 기본 설정 ===
      let mapleader = ","
      set hlsearch
      set ignorecase
      set incsearch
      set noswapfile
      set clipboard=unnamed
      set termguicolors  " treesitter/테마/scrollbar 렌더링에 필요
      set bg=dark
      set nu
      set smartindent
      set shiftwidth=4
      set tabstop=4
      set softtabstop=4
      set expandtab
      syntax on
      filetype indent plugin on
  
      " === 플러그인 관련 ===
      let g:terraform_fmt_on_save = 1
      let python_version_3 = 1
      let python_highlight_all = 1
  
      " === 키맵 ===
      nnoremap <esc>t :tabnew<CR>
      nnoremap <esc>T :-tabnew<CR>
      nnoremap <esc>1 1gt
      nnoremap <esc>2 2gt
      nnoremap <esc>3 3gt
      nnoremap <esc>4 4gt
      nnoremap <esc>5 5gt
      nnoremap <esc>6 6gt
      nnoremap <esc>7 7gt
      nnoremap <esc>8 8gt
      nnoremap <esc>9 9gt
  
      nnoremap <esc>b :Files<CR>
      nnoremap <esc>f :Rg<CR>
      nnoremap <esc>h :History<CR>
  
      " Ctrl + s = save
      nnoremap <silent> <C-s>      :update<CR>
      inoremap <silent> <C-s> <ESC>:update<CR>
      vnoremap <silent> <C-s> <ESC>:update<CR>
  
      " Mundo shortcut
      nnoremap <silent> <Leader>h :MundoToggle<CR>
  
      set undodir=~/.vim/undodir
      set undofile
      set mouse=
    '';
  };
  home.file.".vim/undodir/.keep".text = "";

  # neovim lua 모듈 (init.lua 에서 require("ui")/require("rust") 로 로드)
  home.file.".config/nvim/lua/ui.lua".source = ./nvim/ui.lua;
  home.file.".config/nvim/lua/rust.lua".source = ./nvim/rust.lua;
  home.file.".config/nvim/lua/nix_paths.lua".text = nvimNixPaths;

  # iTerm2 설정: 커스텀 폴더에 plist/프로필을 배치하고 그 폴더를 쓰도록 강제
  home.activation.iterm2Prefs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -eu
    user="${config.home.username}"
    uid="$(/usr/bin/id -u "$user")"

    /bin/mkdir -p "${itermCustomDir}/"
    /bin/cp -f ${srcPlist} "${itermCustomDir}/com.googlecode.iterm2.plist" || true

    /bin/launchctl asuser "$uid" /usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "${itermCustomDir}"
    /bin/launchctl asuser "$uid" /usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true

    /bin/launchctl asuser "$uid" /usr/bin/killall cfprefsd 2>/dev/null || true
  '';

  home.sessionPath = [
    "${config.home.homeDirectory}/dotfiles/home/bin"
    "${config.home.homeDirectory}/bin"
  ];
}
