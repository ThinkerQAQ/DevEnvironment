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

echo "dev-base verification passed"
