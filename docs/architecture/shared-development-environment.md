# Shared Development Environment Architecture

## 1. Domain definition

A shared development environment is a **public, reproducible platform layer that supplies stable cross-project toolchains while each consuming repository keeps ownership of its source code, project control plane, project-specific versions, secrets, data, and runtime behavior**.

That gives four hard boundaries:

- **Public:** never bake private source code, credentials, cookies, databases, or project configuration into an image.
- **Reproducible:** versions live in `versions/tools.env`; published tags are derived from environment definitions.
- **Platform layer:** shared images contain only stable cross-project toolchains.
- **Project ownership:** project-specific versions and runtime behavior stay in the consuming repository and its DEVTool.

## 2. Image model

```text
dev-base
├── Go 1.27.1
├── Node 24 / npm
├── uv
├── Git / curl / ripgrep / SSH / zip
├── gopls 0.23.0
├── Serena 1.7.0
└── CodeGraph 0.20.1
     │
     ▼
dev-android
├── everything in dev-base
├── JDK 17
├── Gradle 8.9
├── Android Platform 35
├── Build Tools 34.0.0 + 35.0.0
├── NDK r30
└── make / pkg-config
```

`dev-android` inherits `dev-base`; a consumer starts one Android container, not two sidecars.

## 3. Consumer mapping

| Repository/workload | Shared profile | Project-owned additions |
| --- | --- | --- |
| go-tiny-claw | `dev-base` | project dependencies and commands |
| IDFlow | `dev-base` | TypeScript 6.0.3, TypeScript Language Server 6.0.1, browser/extension runtime |
| PhotoWaypoint | `dev-android` | matching gomobile/gobind, DEVTool, PostgreSQL/runtime services, host ADB |
| DownKit bridge/desktop | `dev-base` | FFmpeg/yt-dlp/whisper/llama/release behavior |
| DownKit Android | `dev-android` | matching gomobile/gobind, FFmpeg Android build configuration |

## 4. Why gomobile/gobind are project-owned

PhotoWaypoint currently pins:

```text
golang.org/x/mobile v0.0.0-20260204172633-1dceadbbeea3
```

DownKit currently pins:

```text
golang.org/x/mobile v0.0.0-20240326195318-268e6c3a80d1
```

DownKit explicitly validates that `gomobile` and `gobind` match `bridge/go.mod`. A single mobile-tool version baked into `dev-android` would make at least one consumer incorrect.

The shared Android image therefore provides Go + JDK + SDK + NDK only. It carries both Build Tools 34.0.0 and 35.0.0 because current consumers span Android Gradle Plugin defaults across that boundary; each project still owns its AGP version and resolves the exact mobile tools required by its own module.

## 5. Why there is no browser profile yet

IDFlow currently needs Go, Node/npm and TypeScript to build. Chrome/Edge execution is a host/browser-session boundary, not a generic build dependency.

Add `dev-browser` only after a real cross-project requirement appears, such as Playwright/Chromium-based E2E execution.

## 6. Why there is no media profile yet

DownKit uses FFmpeg, yt-dlp, whisper.cpp and llama.cpp, but those are part of DownKit's product/release domain. The shared environment supplies generic prerequisites such as Go and Android NDK/make; DownKit keeps component versions, configure flags, licensing and packaging.

## 7. Version and release model

`versions/tools.env` is the single source of truth for shared platform versions.

`scripts/image-tags.sh` derives immutable tags:

```text
ghcr.io/thinkerqaq/dev-base:env-<base-hash>
ghcr.io/thinkerqaq/dev-android:env-<android-hash>
```

The Android hash includes the base hash, so every base-environment change creates a new Android environment identity.

GitHub Actions uses this flow:

```text
Pull Request
  → validate scripts and Dockerfiles

main push / manual dispatch
  → build + push dev-base
  → verify pulled dev-base
  → build dev-android FROM exact dev-base digest
  → push dev-android
  → verify pulled dev-android
```

There is intentionally no mutable `latest` contract.

## 8. Consumer contract

A consuming repository should declare one profile and one exact image reference, preferably a digest:

```toml
[dev.environment]
profile = "android"
image = "ghcr.io/thinkerqaq/dev-android@sha256:..."
```

Its DEVTool then performs:

```text
read image pin
  → docker pull exact digest
  → mount current worktree
  → mount shared caches
  → execute project command
```

Business-source changes do not rebuild DevEnvironment images.

## 9. Runtime ownership remains project-local

DevEnvironment does not standardize project runtime topology.

For PhotoWaypoint:

```text
Local Agent
  → PhotoWaypoint DEVTool
  → dev-android + shared PostgreSQL + branch services
  → host ADB for physical-device transport
```

For remote ChatGPT:

```text
ChatGPT
  → thin remote gateway
  → PhotoWaypoint DEVTool
  → same Docker runtime
```

## 10. Initial acceptance criteria

1. `dev-base` builds on a public GitHub-hosted runner and publishes to GHCR.
2. `dev-android` builds from the exact published base digest.
3. Both images pass post-push smoke verification.
4. GHCR package visibility permits intended consumers to pull the images.
5. PhotoWaypoint can replace its project-local development Dockerfile with a pinned `dev-android` image.
6. go-tiny-claw and IDFlow can use `dev-base`.
7. DownKit Android can use `dev-android` without changing its own x/mobile pin.
