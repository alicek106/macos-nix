{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "alicek106";
      # 퇴사하면 다른 값으로 변경할 것
      user.email = "chanho.yong@devsisters.com";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      url."git@github.com:".insteadOf = "https://github.com/";
      core.editor = "vim";
    };
    ignores = [ ".DS_Store" ".direnv" "result" ".env" ".env.*" "!.env.example" ".envrc" ];
  };
}
