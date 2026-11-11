# macos-nix

nix-darwin 과 home-manager 로 맥 두 대의 패키지, macOS 환경설정, 셸 설정을 관리한다.

| 호스트 | 기기 |
|---|---|
| `alicek106-m4` | M4 MacBook |
| `alicek106-m1` | M1 Mac Studio |

두 호스트는 같은 설정을 쓰고, 호스트 이름만 다르다.

## 디렉터리 구조

```
flake.nix              # input(패키지 채널 등)과 호스트 목록
Makefile               # 빌드, 적용, 업데이트 명령
overlays/default.nix   # pkgs.unstable, pkgs.go_1_24_2, 직접 빌드하는 패키지를 pkgs 에 추가
pkgs/                  # 직접 빌드하는 패키지 (kubectl-sniff)
darwin/                # 시스템 설정 (nix-darwin)
  default.nix          #   시스템 기본값, home-manager 연결
  packages.nix         #   시스템 패키지(용도별 목록)와 폰트
  defaults.nix         #   macOS 환경설정, Dock
home/                  # 사용자 설정 (home-manager)
  default.nix          #   아래 파일을 불러오는 시작점
  shell.nix            #   zsh, starship, fzf, direnv, eza
  infra.nix            #   kubernetes, terraform, AWS, Vault 관련 alias 와 환경 변수
  git.nix
  neovim.nix           #   lua 설정은 nvim/ 에 있음
  iterm2.nix           #   plist 는 iterm2/ 에 있음
docs/live-drift.md     # 라이브 상태와 설정의 차이 점검 결과
```

## 자주 쓰는 명령

`make` 만 입력하면 명령 목록을 보여 준다. 호스트는 현재 맥의 LocalHostName 으로 정해지며, 다른 호스트를 빌드하려면 `make build HOST=alicek106-m1` 처럼 지정한다.

| 명령 | 동작 |
|---|---|
| `make build` | 빌드만 함 (결과는 `./result`) |
| `make diff` | 지금 적용된 시스템과 빌드 결과의 패키지 버전 차이 출력 |
| `make switch` | 빌드해서 적용 (sudo 필요) |
| `make update-unstable` | unstable 채널만 갱신 |
| `make update` | 모든 flake input 갱신 |
| `make gc` | 7일보다 오래된 시스템 세대와 쓰지 않는 store 경로 삭제 (sudo 필요) |
| `make fmt` | nix 파일 포맷 (nixpkgs-fmt) |
| `make check` | flake 평가 오류 검사 |

## 패키지 버전 관리

### 패키지 채널

flake.nix 에는 nixpkgs 채널을 두 개 둔다.

- **stable** (`nixpkgs`, 지금은 26.05): 기본 채널. 릴리스 안에서는 보안 수정 위주로만 바뀌어서 갱신해도 깨질 가능성이 낮음 (nix-darwin, home-manager 도 같은 릴리스 브랜치 사용)
- **unstable** (`nixpkgs-unstable`): overlay 에서 `pkgs.unstable` 로 노출하며 아래 경우에만 사용
  - 자주 갱신해야 하는 도구 (예: `unstable.claude-code`)
  - stable 에 없는 패키지 (예: `unstable.keepingyouawake`)
  - stable 버전이 지금 쓰는 버전보다 낮거나, stable 패키지가 빌드되지 않거나 바이너리 캐시에 없는 경우

어느 패키지를 unstable 에서 가져오는지와 그 이유는 `darwin/packages.nix` 의 주석에 적어 둔다.

### 패키지 추가

`darwin/packages.nix` 의 알맞은 목록에 이름을 추가한다. 셸 설정과 함께 관리하는 도구(git, starship 등)는 `home/` 의 `programs.<이름>` 으로 설정하며, 이렇게 하면 패키지도 함께 설치되므로 `packages.nix` 에 다시 적지 않는다.

```nix
devTools = with pkgs; [
  ripgrep            # stable
  unstable.some-tool # unstable
];
```

### 버전 갱신

```bash
make update-unstable   # unstable 채널만 갱신 (claude-code 최신화 등)
make diff              # 바뀌는 패키지 버전 확인
make switch            # 적용
```

stable 채널까지 갱신하려면 `make update` 를 쓴다. 새 stable 릴리스(예: 26.11)로 옮길 때는 flake.nix 에서 `nixpkgs`, `nix-darwin`, `home-manager` 세 input 의 버전을 함께 바꾼 뒤 `make update` 를 실행한다.

### 특정 버전 고정

nixpkgs 의 특정 커밋에 있는 버전을 계속 쓰려면, 그 커밋을 flake.nix 에 별도 input 으로 추가하고 `overlays/default.nix` 에서 `pkgs.<이름>` 으로 노출한다. 모듈 안에서 커밋을 직접 `import` 하지 않는다. Go 1.24.2(`nixpkgs-go-1-24-2` input, `pkgs.go_1_24_2`)가 이 방식으로 고정되어 있다.

### 직접 빌드하는 패키지

nixpkgs 에 없는 패키지는 `pkgs/<이름>.nix` 에 derivation 을 작성하고 `overlays/default.nix` 에서 `callPackage` 로 연결한다. 지금은 ksniff 개인 포크(`kubectl-sniff`)만 있다.

## 새 맥 설치 절차

1. 기본 도구 설치
   ```bash
   xcode-select --install
   /usr/sbin/softwareupdate --install-rosetta --agree-to-license
   ```
2. nix 설치 (Determinate Nix)
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
3. 저장소를 `~/dotfiles` 에 받은 뒤 처음 한 번만 nix-darwin 을 직접 실행해 적용한다. 이후에는 `make switch` 를 쓴다.
   ```bash
   sudo nix run github:nix-darwin/nix-darwin/nix-darwin-26.05#darwin-rebuild -- switch --flake .#<호스트>
   ```
4. 아래 "nix 밖에서 설치·설정하는 항목" 을 진행한다.

## nix 밖에서 설치·설정하는 항목

- **Google Chrome**: nix 로 설치하면 Enpass 브라우저 확장이 동작하지 않아 직접 설치
- **Tailscale**: App Store 에서 설치
- **WireGuard VPN**: 프로필을 받아 `/usr/local/etc/wireguard/` 에 두고 `wg-quick up vpn_infra` 실행
  ```bash
  sudo mkdir -p /usr/local/etc/wireguard/
  ```
- **saml2aws**: `saml2aws configure` 실행 (url: `https://auth.<..>.cloud/auth/realms/devsisters/protocol/saml/clients/amazon-aws`)
- **awsctx 프로필**: `git clone git@github.com:<...>/awsctx.git` 으로 받아 `./install.sh profiles` 실행 (셸 함수 `awsctx` 는 이 저장소의 `home/script/awsctx.sh` 에 있음)
- **vaultctx**: 스크립트를 `~/.vaultctx/script` 에 설치 (`home/infra.nix` 의 alias 가 이 경로를 가리킴)
- **terraform**: tfswitch 로 버전별 바이너리를 받아 `~/bin/terraform` 에 둠 (`~/bin` 은 home-manager 가 PATH 에 추가)
- **Claude Code 로그인**: `claude` 실행 후 로그인

## 라이브 상태와 설정의 차이

nix 밖에서 바뀐 설정, 설정에 없는 설치본, 직접 정리해야 하는 파일은 [docs/live-drift.md](docs/live-drift.md) 에 정리되어 있다.

## TODO

- macOS 에 NixOS 를 설치해서 전체를 nix 로 관리하는 구성 만들기
