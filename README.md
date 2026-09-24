# macos-nix

맥북 밀어버릴 때 손으로 해야 하는 초기 세팅들:

- `xcode-select --install`
- `/usr/sbin/softwareupdate --install-rosetta --agree-to-license`
- nix 설치: `curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install`
- build (최초 1회): `sudo nix run github:LnL7/nix-darwin#darwin-rebuild -- switch --flake .#"<호스트>"`
  - `<호스트>`: M4 MacBook = `alicek106-m4`, M1 Mac Studio = `alicek106-m1`
  - 이후에는 `./apply.sh` (현재 LocalHostName으로 설정 선택)
- wireguard profile 내려받고 `sudo mkdir -p /usr/local/etc/wireguard/`
  - profile 파일을 /usr/local/etc/wireguard/ 에 옮겨서 `wg-quick up vpn_infra` (상시)
- `saml2aws configure`
  - url: `https://auth.<..>.cloud/auth/realms/devsisters/protocol/saml/clients/amazon-aws`
- awsctx 내려받고 bash로 install (`git clone git@github.com:<...>/awsctx.git / ./install.sh profiles`)

# TODO
- MacOS에 NixOS 설치해서 full nix 세팅 만들기
