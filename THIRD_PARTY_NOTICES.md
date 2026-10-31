# Third-party component and redistribution boundaries

The [MIT License](LICENSE) covers only original DevEnvironment source code and documentation. Third-party toolchains, dependencies, downloaded binaries, and base images retain their own licenses. This repository does not vendor Android SDK packages or Kotlin LSP binaries.

| Image | Representative components | Distribution condition |
| --- | --- | --- |
| `dev-base` | Go, Node/npm, uv, gopls, Serena, CodeGraph | Review the exact built image, notices, upstream terms, and transitive components before redistribution. |
| `dev-android` | Base image plus JDK, Gradle, Google Android SDK/NDK, JetBrains Kotlin LSP | **Do not redistribute a preinstalled composite image publicly before verifying permission for all components.** |

## Android SDK and Kotlin LSP

Google's [Android SDK Terms](https://developer.android.com/studio/terms) section 3.4 generally restrict copying and redistribution except where third-party license terms apply; section 3.5 separately addresses open-source components. Publishing a Dockerfile is different from distributing SDK binaries within the finished image.

[JetBrains' Kotlin LSP project](https://github.com/Kotlin/kotlin-lsp) describes its implementation as partially closed-source and including proprietary JetBrains components. The whole downloaded archive cannot be assumed to be freely redistributable solely because source code is publicly accessible.

Users must review and accept the applicable third-party terms when building their own development environments. Do not claim a license audit is complete until the precise image contents and required licenses/notices have been reviewed.

## Publishing control

By default GitHub Actions validates Dockerfiles and scripts only. Image publication requires an explicit repository variable `DEVENV_ALLOW_IMAGE_PUBLISH=true`. Enabling that setting is an operational gate, **not legal permission**. Keep GHCR package visibility separate from repository visibility; publishing this source repository does not authorize publishing installed proprietary binaries.
