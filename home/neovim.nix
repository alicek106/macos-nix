# lua 설정은 nvim/ 디렉터리 참고
{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;

    plugins = with pkgs.vimPlugins; [
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

      # UI
      lualine-nvim # 상태 막대
      nvim-web-devicons
      tokyonight-nvim # 다크 테마
      gitsigns-nvim # git 변경 표시
      nvim-autopairs
      indent-blankline-nvim
      nvim-ufo # 코드 접기(folding) UI
      promise-async # nvim-ufo 의존성
      (nvim-treesitter.withPlugins (p: with p; [
        toml
        lua
        json
        yaml
        bash
        markdown
        markdown_inline
        vimdoc
      ]))

      # 파일, 문자열 검색
      telescope-nvim
      plenary-nvim
    ];

    initLua = ''
      require("scrollbar").setup()
      require("ui")
    '';

    extraConfig = ''
      " === 기본 설정 ===
      let mapleader = ","
      set hlsearch
      set ignorecase
      set incsearch
      set noswapfile
      set clipboard=unnamed
      set termguicolors  " treesitter, 테마, scrollbar 를 제대로 표시하려면 필요
      set bg=dark
      set nu
      set foldcolumn=0
      autocmd FileType,BufWinEnter * setlocal foldcolumn=0
      set smartindent
      set shiftwidth=4
      set tabstop=4
      set softtabstop=4
      set expandtab
      syntax on
      filetype indent plugin on

      " === 플러그인 ===
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

      " Ctrl + s 로 저장
      nnoremap <silent> <C-s>      :update<CR>
      inoremap <silent> <C-s> <ESC>:update<CR>
      vnoremap <silent> <C-s> <ESC>:update<CR>

      " Mundo (undo 기록 탐색)
      nnoremap <silent> <Leader>h :MundoToggle<CR>

      set undodir=~/.vim/undodir
      set undofile
      set mouse=

      " === 저장할 때 nix 파일 자동 포맷 (nixpkgs-fmt) ===
      function! FormatNix()
        let l:view = winsaveview()
        silent %!nixpkgs-fmt
        if v:shell_error != 0
          undo
          echohl ErrorMsg | echom "nixpkgs-fmt failed, changes reverted" | echohl None
        endif
        call winrestview(l:view)
      endfunction

      augroup NixFormat
        autocmd!
        autocmd BufWritePre *.nix call FormatNix()
      augroup END
    '';
  };

  # undofile 을 저장할 디렉터리
  home.file.".vim/undodir/.keep".text = "";

  # init.lua 에서 require("ui") 로 불러오는 lua 모듈
  home.file.".config/nvim/lua/ui.lua".source = ./nvim/ui.lua;
}
