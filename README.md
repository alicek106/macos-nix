# macos-nix

맥북 밀어버릴 때 손으로 해야 하는 초기 세팅들:

- `xcode-select --install`
- `/usr/sbin/softwareupdate --install-rosetta --agree-to-license`
- nix 설치: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
- build: `nix run github:LnL7/nix-darwin --switch --flake .#"alicek106-m4"`
- wireguard profile 내려받고 `sudo mkdir -p /usr/local/etc/wireguard/`
  - profile 파일을 /usr/local/etc/wireguard/ 에 옮겨서 `wg-quick up vpn_infra` (상시)
- `saml2aws configure`
  - url: `https://auth.<..>.cloud/auth/realms/devsisters/protocol/saml/clients/amazon-aws`
- awsctx 내려받고 bash로 install (`git clone git@github.com:<...>/awsctx.git / ./install.sh profiles`)
