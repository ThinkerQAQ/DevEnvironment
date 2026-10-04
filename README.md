# DevEnvironment

Public, reusable development environments for ThinkerQAQ repositories.

## Images

| Image | Purpose | Current consumers |
| --- | --- | --- |
| `ghcr.io/thinkerqaq/dev-base` | Go + Node + uv + shared code-intelligence tools | go-tiny-claw, IDFlow, DownKit desktop/bridge |
| `ghcr.io/thinkerqaq/dev-android` | `dev-base` + JDK 17 + Gradle 8.9 + Android SDK/NDK | PhotoWaypoint, DownKit Android |

The images contain **development platform dependencies only**. Project source code, project DevTools, credentials, databases, browser sessions, and project-specific build tools stay in the consuming repositories.

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

Pull requests validate scripts and Dockerfiles. Pushes to `main` build and publish the immutable GHCR tags using the public repository's GitHub-hosted runner.

To inspect the image tags produced by the current source:

```bash
bash scripts/image-tags.sh
```

After the first successful package publish, set the GHCR packages to the visibility required by consuming repositories. Public visibility allows anonymous pull from private projects and cloud development hosts.

See [Shared Development Environment Architecture](docs/architecture/shared-development-environment.md) for the ownership model and consumer mapping.
