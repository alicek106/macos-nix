# macos-nix

```bash
make update-unstable
make diff
make switch
# make build HOST=alicek106-m1
```

## macos install

macos 초기화 후 실행:

1. 기본 도구 설치
   ```bash
   xcode-select --install
   /usr/sbin/softwareupdate --install-rosetta --agree-to-license
   ```
2. nix 설치 (Determinate Nix)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
3. 처음 한 번만 nix-darwin 을 직접 실행해 적용한다. 이후에는 `make switch` 를 사용하면 됨.
   ```bash
   sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#<hostname>
   ```

## 직접 설정해야 하는 항목들

- saml2aws configure
- vaultctx 스크립트를 ~/.vaultctx/script에 설치
- tailscale client 및 profile
- Devsisters wireguard profile
  ```bash
  sudo mkdir -p /usr/local/etc/wireguard/
  ...
  wg-quick up vpn_infra
  ```
