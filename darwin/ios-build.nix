{ lib, username, hostname, ... }:

lib.mkIf (hostname == "alicek106-m1") {
  services.openssh.enable = true;

  users.users.${username}.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG/ZbARmvoy4HkTfYfS7vL/fwp839PWmZ0Sb7BdbsgSN claude-readonly@alicek106-m4"
  ];

  environment.etc."ssh/sshd_config.d/050-tailnet-key-only.conf" = {
    text = ''
      PasswordAuthentication no
      KbdInteractiveAuthentication no
      AllowUsers ${username}@100.64.0.1/32
    '';

    # 원래 손으로 만들었던 파일에 대한 해시값. 지금 한 번만 쓰이고 쓰이지 않는다.
    # 이걸 명시하지 않으면 nix는 자기가 만든 /etc 파일이 아니라고 오류냄 
    knownSha256Hashes = [ "e923fb5e9fa96faa68bc2c8326c46833e2aa6dc05c5ad856d0a649d224b41daf" ];
  };
}
