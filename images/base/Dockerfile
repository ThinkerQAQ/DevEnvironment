# check=skip=InvalidDefaultArgInFrom
ARG NODE_VERSION
ARG UV_VERSION
ARG GO_VERSION

FROM node:${NODE_VERSION}-bookworm-slim AS node
FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv
FROM golang:${GO_VERSION}-bookworm

ARG GOPLS_VERSION
ARG SERENA_VERSION
ARG CODEGRAPH_VERSION

ENV DEBIAN_FRONTEND=noninteractive \
    DEVENV_TOOLS=/opt/devenv-tools \
    GOMODCACHE=/cache/go-mod \
    GOCACHE=/cache/go-build \
    HOME=/tmp/devenv-home

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=uv /uv /uvx /usr/local/bin/

RUN ln -s ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -s ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

ENV PATH=${DEVENV_TOOLS}/bin:${PATH}

RUN test "$(dpkg --print-architecture)" = "amd64" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gosu \
        openssh-client \
        ripgrep \
        unzip \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "${DEVENV_TOOLS}/bin" \
    && GOBIN="${DEVENV_TOOLS}/bin" GOWORK=off \
       go install "golang.org/x/tools/gopls@${GOPLS_VERSION}"

RUN UV_TOOL_DIR="${DEVENV_TOOLS}/uv" \
    UV_TOOL_BIN_DIR="${DEVENV_TOOLS}/bin" \
    uv tool install --python 3.13 "serena-agent==${SERENA_VERSION}"

RUN set -eux; \
    root="${DEVENV_TOOLS}/codegraph"; \
    mkdir -p "${root}"; \
    printf '{"private":true,"dependencies":{"@astudioplus/codegraph-mcp":"%s"},"allowScripts":{"@astudioplus/codegraph-mcp@%s":true}}\n' \
      "${CODEGRAPH_VERSION}" "${CODEGRAPH_VERSION}" > "${root}/package.json"; \
    npm install --prefix "${root}" --omit=dev; \
    engine="${root}/node_modules/@astudioplus/codegraph-mcp/bin/codegraph-server-linux-x64"; \
    test -x "${engine}"; \
    ln -s "${engine}" "${DEVENV_TOOLS}/bin/codegraph-server"

ENV CODEGRAPH_SERVER_PATH=/opt/devenv-tools/bin/codegraph-server

COPY entrypoint.sh /usr/local/bin/devenv-entrypoint
RUN chmod 0755 /usr/local/bin/devenv-entrypoint

WORKDIR /workspace
ENTRYPOINT ["/usr/local/bin/devenv-entrypoint"]
