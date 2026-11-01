# DevEnvironment

[简体中文](README_ZH.md)

- [1. Introduction](#1-introduction)
- [2. Quick Start](#2-quick-start)
- [3. Configuration](#3-configuration)
- [4. Optional Features](#4-optional-features)
- [5. Development](#5-development)
- [6. License](#6-license)

## 1. Introduction

Setting up a development machine repeatedly means installing compilers, language servers, and command-line tools, then tracking down version differences when a project works on one computer but not another.

DevEnvironment keeps commonly used toolchains in **reproducible Linux Docker images**. The base image provides Go, Node.js, uv, and code-intelligence tools; the optional Android image adds Java, Gradle, Kotlin LSP, and Android SDK/NDK. You build the image once and run development tools against the project directories you choose to mount.

This repository provides **image definitions**, not a desktop application or a one-click installer. It can be used independently of [DevTool](https://github.com/ThinkerQAQ/DevTool), which is an archived experimental project. Your application code, credentials, and business-specific dependencies remain outside the shared image.

## 2. Quick Start

Follow this local first-run path: clone the definitions, build the base image, verify the installed tools, and run a small Go program. No GHCR account or prepublished image is required.

### 2.1. Prerequisites

A Linux **amd64** Docker engine with Buildx, Bash, Git and `sha256sum` (GNU coreutils), network access to the upstream distributions, and enough disk for toolchains. On Windows use Docker Desktop's Linux containers with a Bash environment such as WSL; on macOS install coreutils if `sha256sum` is absent. These are Linux images, not native Windows/macOS environments. The Dockerfiles enforce amd64; ARM hosts require explicit Linux/amd64 emulation and are not a native ARM support claim.

### 2.2. Clone and load the pinned versions

```bash
git clone https://github.com/ThinkerQAQ/DevEnvironment.git
cd DevEnvironment
source versions/tools.env
bash scripts/image-tags.sh
```

The command prints `BASE_TAG=env-...` and `ANDROID_TAG=env-...`. Versions are maintained in `versions/tools.env`; there is no application config or account required for the base workflow.

### 2.3. Build the base image locally

```bash
docker buildx build --load --platform linux/amd64 \
  --build-arg GO_VERSION="$GO_VERSION" \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  --build-arg UV_VERSION="$UV_VERSION" \
  --build-arg GOPLS_VERSION="$GOPLS_VERSION" \
  --build-arg SERENA_VERSION="$SERENA_VERSION" \
  --build-arg CODEGRAPH_VERSION="$CODEGRAPH_VERSION" \
  -t devenv-base:local -f images/base/Dockerfile images/base
```

This can download large upstream toolchains and run their installation hooks. No GHCR account, publishing permission or pre-existing private image is needed for this source build.

### 2.4. Verify and run one program

Run these checks from the same repository directory after the image finishes building.

```bash
docker run --rm --platform linux/amd64 \
  --entrypoint bash -v "$PWD:/repo:ro" \
  devenv-base:local \
  /repo/scripts/verify-base.sh /repo/versions/tools.env

docker run --rm --platform linux/amd64 devenv-base:local \
  sh -c 'printf "package main\nfunc main() { println(42) }\n" > /tmp/hello.go; go run /tmp/hello.go'
```

Success means the verifier prints `dev-base verification passed` and the Go program prints `42`, both with exit code 0. Building an image or resolving tags alone is not the full Quick Start verification.

### 2.5. Troubleshooting

- **Cannot connect to Docker:** start the engine and check `docker info`; source validation does not require an engine, image builds do.
- **`sha256sum` not found:** install GNU coreutils or use a Linux Bash environment.
- **Architecture check fails:** the current images require linux/amd64; do not advertise ARM64 without adapting and testing every bundled binary.
- **Download/hash failure:** check the upstream URL and matching version/checksum in `versions/tools.env`; do not bypass checksum verification.
- **Permission problems in mounted projects:** supply the intended `DEVENV_RUN_UID` and `DEVENV_RUN_GID`; the entrypoint prepares the private home/caches then drops privileges.
- **GHCR pull denied:** public source does not guarantee image availability. Build locally or use an image you are authorized to access.

## 3. Configuration

[versions/tools.env](versions/tools.env) owns shared versions and archive digests. Project-specific tools belong in the consuming repository. Runtime variables:

| Variable | Default/use |
| --- | --- |
| `DEVENV_RUN_UID`, `DEVENV_RUN_GID` | Unset; set both to run as the intended non-root user after entrypoint setup |
| `SERENA_HOME` | `/tmp/devenv-home/.serena`; initialized by the entrypoint |
| `GOMODCACHE`, `GOCACHE` | `/cache/go-mod`, `/cache/go-build` |
| `GRADLE_USER_HOME` | `/cache/gradle` in Android image |

Mount only intended project/cache paths. Immutable `env-<hash>` tags derive from version/build inputs; the Android identity also includes the base hash. For deployed consumers prefer a verified OCI digest. Changing project business source does not require rebuilding a shared toolchain image.

## 4. Optional Features

### 4.1. Case 1: Android toolchain

Only needed for Android projects, after you have reviewed/accepted the applicable SDK and Kotlin LSP terms. From the same Bash session after building the base image:

```bash
android_args=(--build-arg BASE_IMAGE=devenv-base:local)
for key in GRADLE_VERSION GRADLE_SHA256 KOTLIN_LSP_VERSION KOTLIN_LSP_SHA256 ANDROID_CMDLINE_TOOLS_REVISION ANDROID_CMDLINE_TOOLS_SHA256 ANDROID_PLATFORM ANDROID_BUILD_TOOLS ANDROID_BUILD_TOOLS_COMPAT ANDROID_NDK; do
  android_args+=(--build-arg "$key=${!key}")
done
docker buildx build --load --platform linux/amd64 \
  "${android_args[@]}" \
  -t devenv-android:local -f images/android/Dockerfile images/android

docker run --rm --platform linux/amd64 \
  --entrypoint bash -v "$PWD:/repo:ro" \
  devenv-android:local \
  /repo/scripts/verify-android.sh /repo/versions/tools.env
```

Require `dev-android verification passed`. This is substantially larger than the base workflow. When a non-default Buildx driver cannot resolve a locally loaded base image, use the default Docker driver or an authorized registry digest. The Android Dockerfile runs SDK license acceptance commands; building does not grant redistribution rights.

Project mounts and cache volumes are optional. The images deliberately do not own gomobile/gobind, project TypeScript tooling, media engines or release packaging.

## 5. Development

```bash
for script in images/base/entrypoint.sh scripts/*.sh; do bash -n "$script"; done
bash scripts/image-tags.sh
```

There is no standalone application/unit-test suite. The existing CI validates shell syntax, tags and Dockerfile Buildx checks. The Quick Start above is the local build/run verification. Publishing is disabled unless repository variable `DEVENV_ALLOW_IMAGE_PUBLISH=true` is deliberately enabled after component-license review; do not enable it merely for a documentation change. Authorized publishing builds both images, runs verification scripts and records digests. Use feature branches, PRs and Squash Merge. Native Windows/macOS host behavior and ARM emulation need separate checks.

## 6. License

Build definitions are [MIT](LICENSE). This does not relicense installed toolchains, Google Android SDK or proprietary Kotlin LSP binaries. Review [third-party notices](THIRD_PARTY_NOTICES.md) before any image redistribution. Public repository visibility and GHCR package visibility are independent. Credentials, browser sessions, databases, source projects and runtime caches must not be baked into published layers.
