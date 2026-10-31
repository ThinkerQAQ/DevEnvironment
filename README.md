# DevEnvironment

[简体中文](README_ZH.md) · [MIT License](LICENSE) · [Third-party notices](THIRD_PARTY_NOTICES.md)

**Status: experimental shared tooling; open-source build definitions, separately reviewed image distribution.**

Reusable development environments for ThinkerQAQ repositories. This is companion infrastructure to [DevTool (formerly DEV2)](https://github.com/ThinkerQAQ/DevTool): DevTool owns the Docker environment provider and project lifecycle, whereas DevEnvironment owns shared toolchain definitions and immutable image references. Both can be used independently.

## Images

| Image | Purpose | Current consumers |
| --- | --- | --- |
| `ghcr.io/thinkerqaq/dev-base` | Go + Node + uv + shared code-intelligence tools (gopls, Serena, CodeGraph) | go-tiny-claw, IDFlow, DownKit desktop/bridge |
| `ghcr.io/thinkerqaq/dev-android` | `dev-base` + Kotlin LSP + JDK 17 + Gradle 8.9 + Android SDK/NDK | PhotoWaypoint, DownKit Android |

The images contain **development platform dependencies only**. Project source code, project DevTools, credentials, databases, browser sessions, and project-specific build tools stay in the consuming repositories.

### Kotlin language intelligence

`dev-android` preinstalls the Kotlin Language Server and points Serena at that executable through its runtime-global `ls_specific_settings`.

The image downloads Kotlin LSP from JetBrains' stable `download.jetbrains.com` entrypoint and verifies the exact SHA256 from `versions/tools.env`. Serena therefore does not depend on its managed direct-CDN download path at runtime.

Kotlin LSP is a shared code-intelligence dependency, so its version belongs to DevEnvironment rather than to PhotoWaypoint or DevTool.

The shared images intentionally do **not** own:

- `gomobile` / `gobind` versions — PhotoWaypoint and DownKit currently require different `golang.org/x/mobile` revisions;
- TypeScript / TypeScript Language Server versions — IDFlow owns those versions;
- FFmpeg, yt-dlp, whisper.cpp, llama.cpp, or release packaging — DownKit owns those components.

## Versioning

Every build receives an immutable content-derived tag:

```text
ghcr.io/thinkerqaq/dev-base:env-<hash>
ghcr.io/thinkerqaq/dev-android:env-<hash>
```

The Android tag includes the base-image environment hash, so a base environment change always produces a new Android environment identity.

Consuming repositories should pin an exact tag and preferably an exact OCI digest:

```text
ghcr.io/thinkerqaq/dev-android@sha256:...
```

Business-source changes in a consuming repository never rebuild these images.

## Repository layout

```text
images/
  base/
    Dockerfile
    entrypoint.sh
  android/
    Dockerfile

versions/
  tools.env

scripts/
  image-tags.sh
  verify-base.sh
  verify-android.sh

docs/
  architecture/
    shared-development-environment.md
```

## CI

Pull requests and pushes to `main` validate scripts and Dockerfiles. **Image publishing is disabled by default** and requires setting the repository variable `DEVENV_ALLOW_IMAGE_PUBLISH=true` after exact-component license/redistribution review. This is an operational guard, not permission to redistribute. See [third-party notices](THIRD_PARTY_NOTICES.md).

To inspect the image tags produced by the current source:

```bash
bash scripts/image-tags.sh
```

Keep GHCR package visibility independent of repository visibility. Do not make preinstalled Android images public without verified redistribution permission for the Google Android SDK and proprietary Kotlin LSP components. Existing digest-pinned consumers can continue using packages they are authorized to access.

See [Shared Development Environment Architecture](docs/architecture/shared-development-environment.md) for the ownership model and consumer mapping.
