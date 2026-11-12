# 업데이트 방법: version 을 변경하고 hash 를 "" 로 설정한 뒤 빌드하면 hash가 출력되는데 그걸로 교체할 것
{ fetchurl }:

let
  version = "2026.9";
in
fetchurl {
  url = "https://github.com/northpolesec/santa/releases/download/${version}/santa-${version}.pkg";
  hash = "sha256-loIbZDnVHs4pkeHZqN3ZlpxieDkTJdjnOQT/CWHf9uo=";
  passthru = { inherit version; };
}
