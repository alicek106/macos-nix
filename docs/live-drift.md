# 라이브 상태와 설정의 차이

2026-11-11 에 M4 MacBook(`alicek106-m4`)을 점검한 결과다. 점검 시점에 적용되어 있던 시스템은 커밋 `723154a` 의 설정을 빌드한 결과와 같았으므로, 아래 항목은 그 설정과 실제 상태가 어긋나거나 설정 밖에 있는 것이다.

항목마다 조치 방법을 아래 세 가지 중 하나로 표시했다.

- **적용하면 해결**: 이 저장소의 현재 설정을 `make switch` 로 적용하면 해결됨
- **직접 조치**: 적힌 명령을 직접 실행해야 함
- **판단 필요**: nix 로 옮길지 그대로 둘지 정해야 함

## 요약

| 항목 | 상태 | 조치 |
|---|---|---|
| nix store 경로의 내용 변경 | iTerm2, VS Code, nodejs, gitconfig | 적용하면 해결 |
| nix 패키지를 가리는 nix 밖 설치본 | claude, kubectl | 직접 조치 |
| AWS CLI v1 이 v2 를 가림 | nix awscli 1.42 가 우선 | 적용하면 해결 |
| 이전 설정이 남긴 앱 링크 폴더 | `~/Applications/Nix Apps` | 적용 후 직접 조치 |
| pip 로 설치한 Python 명령 | nix python 경로에 묶여 있음 | 적용 후 직접 조치 |
| 더 이상 쓰지 않는 파일 | zinit, treesitter 파서 등 | 적용 후 직접 조치 |
| 설정 밖의 앱, CLI, 홈 파일 | 직접 설치한 앱 약 30개 등 | 판단 필요 |

## nix store 경로의 내용 변경

nix 는 store 경로의 내용이 빌드 후 바뀌지 않는다는 전제로 동작하는데, 아래 경로는 빌드 후에 내용이 바뀌었다 (`nix-store --verify-path` 결과 modified).

| store 경로 | 바뀐 내용 | 원인 |
|---|---|---|
| `iterm2-3.5.14` | 앱 버전이 3.7.1 로 바뀜 | iTerm2 자동 업데이트가 store 안의 앱을 덮어씀 |
| `vscode-1.103.2` | 앱 버전이 1.123.0 으로 바뀜 | VS Code 자동 업데이트가 store 안의 앱을 덮어씀 |
| `nodejs-24.7.0` | `@openai/codex` 추가 | npm 전역 설치 경로가 nodejs store 경로라서 `npm i -g` 가 store 에 씀 |
| `hm_gitconfig` | `user.email` 이 회사 주소로 바뀜 | store 의 gitconfig 파일을 직접 수정 |

**적용하면 해결.** 26.05 로 올리면서 네 패키지 모두 새 store 경로를 쓰고, 회사 이메일은 `home/git.nix` 에 선언했다. 내용이 바뀐 옛 경로는 이전 시스템 세대가 `make gc` 로 지워질 때 함께 지워진다.

이전 설정에서는 Dock 이 store 경로를 가리키는 링크로 앱을 실행했기 때문에, 앱이 스스로 업데이트하면 store 안의 파일이 바뀌었다. 지금은 nix-darwin 이 `/Applications/Nix Apps` 에 복사해 둔 앱을 실행하므로 store 는 바뀌지 않는다. 같은 일이 다시 생기지 않도록 아래 내용을 확인한다.

- **앱 자동 업데이트**: 스스로 업데이트한 앱은 다음 적용 때 nix 버전으로 되돌아가므로 끄는 것이 좋음
  - iTerm2: 이미 꺼져 있음
  - VS Code: settings.json 에 `"update.mode": "none"` 추가
- **npm 전역 설치 경로 (판단 필요)**: `npm config set prefix ~/.npm-global` 로 store 밖으로 옮기고 `~/.npm-global/bin` 을 PATH 에 추가

## nix 패키지를 가리는 nix 밖 설치본

PATH 에서 nix 경로보다 앞에 있는 설치본 때문에 nix 로 설치한 버전이 쓰이지 않는 명령이다. `~/.zprofile`(Codex 설치 프로그램이 추가한 파일)이 `~/.local/bin` 을 PATH 맨 앞에 넣고, home-manager 가 `~/bin` 을 nix 경로보다 앞에 넣는다.

| 명령 | 실제로 실행되는 것 | nix 버전 (26.05 적용 후) | 조치 |
|---|---|---|---|
| `claude` | `~/.local/bin/claude` (네이티브 설치본 2.1.322) | 2.1.318 (unstable) | 직접 조치 |
| `kubectl` | `~/bin/kubectl` (1.35.3) | 1.36.3 | 직접 조치 |
| `kubectl krew` | `~/.krew/bin/kubectl-krew` (krew 가 스스로 업데이트한 0.5.0) | 0.5.0 | 조치 필요 없음 |
| `codex` | `~/.local/bin/codex` (standalone 설치본 0.147.0) | 없음 (npm 설치본은 적용 후 사라짐) | 조치 필요 없음 |
| `aws` | nix `awscli` 1.42 (v1) 가 `/usr/local/bin/aws` 2.34 (v2) 를 가림 | `awscli2` 2.34.24 | 적용하면 해결 |

- **claude**: 네이티브 설치본을 지워야 nix 버전이 실행됨. 이후 nix 버전은 `make update-unstable` 과 `make switch` 로 갱신
  ```bash
  rm ~/.local/bin/claude
  rm -rf ~/.local/share/claude
  ```
- **kubectl**: 26.05 의 nix 버전이 더 높으므로 `~/bin/kubectl` 삭제 (클러스터 버전에 맞춘 바이너리가 필요하면 유지)
- **aws**: 적용 후 AWS 공식 pkg 로 설치한 `/usr/local/bin/aws`, `/usr/local/bin/aws_completer` 삭제 가능

## 앱

- **`/Applications/Nix Apps`**: 모두 설정에 선언된 패키지
- **App Store 에서 설치**: Developer, Disk Inspector, Fuwari, KakaoTalk, Pages Creator Studio, Paint X, Tailscale, Unicorn HTTPS
- **직접 설치**: boringNotch, Brave Browser, CLIP STUDIO, DBeaver, Discord, Enpass, Firefox, Google Chrome, krita, MapleStory Worlds, OpenVPN Connect, p4admin/p4merge/p4v, Prism Launcher, QuickMD, Raycast, Remote Desktop Manager, VLC, Wacom 도구
- **Dock 앱 순서**: 손으로 바꾼 라이브 순서(VS Code, iTerm2, Slack)를 설정에 반영

Google Chrome 과 Tailscale 은 README 의 수동 설치 항목에 있다. 나머지 중 nixpkgs 에 있는 앱(DBeaver, Discord, Firefox, Raycast, VLC 등)은 `darwin/packages.nix` 의 `guiApps` 로 옮길 수 있다 (판단 필요).

`~/Applications/Nix Apps` 는 이전 설정이 만든 링크 폴더이며 지금 설정은 이 폴더를 쓰지 않는다. 설정에 없는 `Ghostty.app`(커밋되지 않은 설정으로 적용된 적 있음)과 `Google Chrome.app`(139 버전) 링크도 남아 있다. 적용 후 root 소유 폴더이므로 sudo 로 지운다 (직접 조치).

```bash
sudo rm -rf ~/Applications/"Nix Apps"
```

## nix 밖에서 설치한 CLI

- **`~/bin`**: `terraform`(tfswitch 가 `~/.terraform.versions` 에 받아 둔 바이너리), `kubectl`
- **`~/.local/bin`**:
  - 단독 바이너리: ast-grep, codebase-memory-mcp, coderabbit, magika
  - 설치 프로그램이 관리: claude(네이티브), codex(standalone)
  - uv tool: poetry, quokka
  - `pip install --user` 로 설치한 Python 명령 약 50개 (litellm, hf, fastapi 등, 패키지는 `~/.local/lib/python3.12/site-packages` 에 1.7 GB)
- **`~/.krew/bin`**: krew 플러그인 (cert-manager, detached, node-resource, node-shell, stern, view-utilization)
- **`/usr/local/bin`**: aws, databricks, kc2aws, kubectl-argo-rollouts, session-manager-plugin, tfswitch, pantry
- **PATH 에 없는 디렉터리**: `~/go/bin`(gopls, staticcheck 등), `~/.cargo/bin`(rustup, sqlx, mdbook). `~/.profile` 이 `~/.cargo/env` 를 읽지만 zsh 는 `.profile` 을 읽지 않음

직접 조치가 필요한 항목:

- **pip 로 설치한 Python 명령**: 첫 줄(shebang)이 nix python312(3.12.11)의 store 경로를 가리킴. 26.05 의 python312 는 3.12.15 이므로, 적용 후 `make gc` 로 이전 세대가 지워지면 이 명령들이 실행되지 않음. 적용 후 다시 설치하거나 `uv tool install` 로 옮김
- **`/usr/local/bin/kubectl-cert_manager`**: Linux 용 바이너리라 실행되지 않음 (krew 설치본이 앞에 있어 가려져 있음)
  ```bash
  sudo rm /usr/local/bin/kubectl-cert_manager
  ```

## 홈 디렉터리 파일

home-manager 가 관리하지 않는 파일:

- `~/.zprofile`: Codex 설치 프로그램이 추가한 PATH 설정
- `~/.profile`: `~/.cargo/env` 를 읽는 한 줄 (zsh 는 읽지 않음)
- `~/.config/direnv/direnv.toml`: direnv 로그 형식 설정
- `~/.ssh/config`

이전 설정이 남긴 파일 (적용 후 직접 조치):

- `~/.local/share/zinit`: zsh-expand-all 은 이제 home-manager 가 설치함. 지우면 PATH 맨 앞의 `~/.local/share/zinit/polaris/bin` 도 사라짐
- `~/.local/share/nvim/treesitter-parsers`: treesitter 파서는 nix 로 설치함
- `~/.nix-profile`: 대상이 없는 링크
- `~/.zcompdump.alicek106-m4.*`: 예전 zsh 자동 완성 캐시

```bash
rm -rf ~/.local/share/zinit ~/.local/share/nvim/treesitter-parsers
rm ~/.nix-profile ~/.zcompdump.alicek106-m4.*
```

그 밖의 확인 결과:

- **iTerm2**: `home/iterm2/plist-diff.sh` 결과 저장소의 plist 와 사용 중인 plist 가 같음
- **awsctx**: 프로필 링크가 `~/github/awsctx/profiles/` 를 가리키며 끊어진 링크 없음

## macOS 환경설정과 로그인 셸

- **`-currentHost` 탭 클릭 설정**: `defaults -currentHost` 의 `com.apple.mouse.tapBehavior` 가 설정되어 있지 않음. 이전 설정의 activation 스크립트가 root 권한으로 실행되어 사용자 설정에 반영되지 않은 것으로 보임. 사용자 수준의 값은 `system.defaults` 가 이미 설정하므로 이 스크립트는 삭제함
- **로그인 셸**: `/bin/zsh`. 이전 설정의 `users.users.alicek106.shell = pkgs.zsh` 는 nix-darwin 이 `users.knownUsers` 에 있는 사용자에게만 적용하므로 효과가 없어 삭제함. `/bin/zsh` 도 home-manager 가 만든 `~/.zshrc` 를 읽으므로 셸 설정은 그대로 적용됨

## 설치된 앱이 없는 LaunchAgent, LaunchDaemon

아래 항목은 해당 앱이 지워졌는데 남아 있다 (직접 조치).

- `~/Library/LaunchAgents/com.DigiDNA.iMazing2Mac.Mini.plist` (iMazing)
- `/Library/LaunchDaemons/com.amazon.workspaces.updater.plist` (Amazon WorkSpaces)
- `/Library/LaunchDaemons/com.interezen.nwsdaemon.plist` (IPinside)

```bash
launchctl bootout gui/$(id -u) ~/Library/LaunchAgents/com.DigiDNA.iMazing2Mac.Mini.plist
rm ~/Library/LaunchAgents/com.DigiDNA.iMazing2Mac.Mini.plist
sudo launchctl bootout system /Library/LaunchDaemons/com.amazon.workspaces.updater.plist
sudo launchctl bootout system /Library/LaunchDaemons/com.interezen.nwsdaemon.plist
sudo rm /Library/LaunchDaemons/com.amazon.workspaces.updater.plist /Library/LaunchDaemons/com.interezen.nwsdaemon.plist
```

## nix 프로필과 시스템 세대

- **직접 설치한 nix 패키지**: 없음 (`nix profile`, `nix-env` 모두 비어 있음)
- **시스템 세대**: 점검 시점에 142개, `/nix/store` 81 GB. `make gc` 로 7일보다 오래된 세대 삭제
