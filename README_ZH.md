# DevEnvironment

[English](README.md) · [架构说明](docs/architecture/shared-development-environment.md) · [MIT License](LICENSE) · [第三方组件声明](THIRD_PARTY_NOTICES.md)

**状态：实验性共享开发基础设施；源码可公开，预装工具链镜像的分发需要单独审核。**

本项目是 [DevTool（原 DEV2）](https://github.com/ThinkerQAQ/DevTool) 的配套基础设施，但可以独立使用。DevTool 负责环境 Provider 的契约与生命周期；DevEnvironment 负责 Go、Node 和 Android 工具链的镜像定义、版本以及验证。

| 镜像 | 内容 |
| --- | --- |
| `ghcr.io/thinkerqaq/dev-base` | Go、Node、uv、gopls、Serena、CodeGraph |
| `ghcr.io/thinkerqaq/dev-android` | dev-base + JDK、Gradle、Android SDK/NDK、Kotlin LSP |

所有工具版本集中在 `versions/tools.env`；`scripts/image-tags.sh` 生成内容标签。消费方应固定确切 digest。项目源代码、Cookies、凭据、数据库和业务特有工具均不应进入通用镜像。

## 构建与合法分发

本仓库提供 Dockerfile、检查脚本和架构说明。自行构建 Android 镜像时，用户需遵守 Google 和 JetBrains 相关许可。**源码 MIT 不覆盖镜像中下载的第三方二进制**。完整边界见 [第三方组件声明](THIRD_PARTY_NOTICES.md)。

GitHub Actions 默认只验证脚本和 Dockerfile。只有明确设置仓库变量 `DEVENV_ALLOW_IMAGE_PUBLISH=true`，才会执行镜像发布任务；设置变量不等于取得分发授权。未经完整许可审核，不应公开发布包含 Android SDK / Kotlin LSP 的预装镜像。

项目当前不承诺持续维护或生产环境兼容性；源码与设计可供学习、复用及独立改进。
