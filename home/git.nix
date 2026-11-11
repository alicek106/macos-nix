# git 사용자 정보와 기본 동작
{ ... }:

{
  programs.git = {
    enable = true;
    userName = "alicek106";
    userEmail = "chanho.yong@devsisters.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      # GitHub 저장소를 https 주소로 지정해도 ssh 로 접속한다.
      url."git@github.com:".insteadOf = "https://github.com/";
      core.editor = "vim";
    };
    ignores = [ ".DS_Store" ".direnv" "result" ];
  };
}
