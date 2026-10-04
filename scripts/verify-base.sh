#!/usr/bin/env bash
set -euo pipefail

versions="${1:-/repo/versions/tools.env}"
# shellcheck disable=SC1090
source "$versions"

go version | grep -F "go${GO_VERSION} "
node --version | grep -E "^v${NODE_VERSION}(\\.|$)"
uv --version | grep -F "${UV_VERSION}"
gopls version | grep -F "${GOPLS_VERSION}"
command -v serena >/dev/null
serena --help >/dev/null
command -v codegraph-server >/dev/null
test -x "${CODEGRAPH_SERVER_PATH}"
command -v git >/dev/null
command -v rg >/dev/null

for cache_dir in /cache/go-mod /cache/go-build /cache/gradle; do
  if [ -d "$cache_dir" ] && [ -n "$(find "$cache_dir" -mindepth 1 -maxdepth 1 -print -quit)" ]; then
    echo "runtime cache must be empty in the published image: $cache_dir" >&2
    exit 1
  fi
done

test -x "${DEVENV_TOOLS}/uv/serena-agent/bin/python"

echo "dev-base verification passed"
