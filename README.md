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
- santa: `open /etc/santa/santa.mobileconfig` 후 시스템 설정 > 일반 > 기기 관리에서 설치하면 됨. `santactl status` 의 Watch Items 가 Enabled 이면 정상.

## TODO

- 현재 /**/bin/ 에 직접 설치하는 도구들이 몇몇 있는데, userspace에서 수정 가능한 binary 경로이므로 nix로 다 바꿀 것. 그리고 나서 `darwin/santa-faa.nix` 에 일괄 추가할 것.

참고: santa, lulu 등 nix로 설치되지 않은 항목들은 nix에서 삭제해도 완전히 삭제되지 않으므로 pkg가 제공하는 uninstall 가이드를 따라야 함.
