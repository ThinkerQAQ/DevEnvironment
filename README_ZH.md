# DevEnvironment

[English](README.md)

## 项目简介

实验性的共享 Docker 开发工具链构建定义。`dev-base` 提供 Go、Node.js、uv 与代码智能工具；`dev-android` 增加 JDK 17、Gradle、Kotlin LSP 和 Android SDK/NDK。适合需要可复现项目环境的开发者。DevTool 可以使用这些镜像，但构建和运行不依赖 DevTool。项目代码、凭据及业务专用工具不放入镜像。

## 快速开始

### 1. 前置条件

Linux **amd64** Docker 引擎、Buildx、Bash、Git、`sha256sum`（GNU coreutils），可访问上游发行源的网络，以及容纳工具链的磁盘空间。Windows 使用 Docker Desktop Linux 容器及 WSL 等 Bash 环境；macOS 缺少 `sha256sum` 时安装 coreutils。这是 Linux 镜像，不是 Windows/macOS 原生环境。Dockerfile 强制 amd64，ARM 主机需要显式 Linux/amd64 模拟，不代表原生 ARM 支持。

### 2. 克隆并加载固定版本

```bash
git clone https://github.com/ThinkerQAQ/DevEnvironment.git
cd DevEnvironment
source versions/tools.env
bash scripts/image-tags.sh
```

输出应包含 `BASE_TAG=env-...`、`ANDROID_TAG=env-...`。工具版本维护在 `versions/tools.env`，基础流程不需要应用配置或账户。

### 3. 本地构建基础镜像

```bash
docker buildx build --load --platform linux/amd64   --build-arg GO_VERSION="$GO_VERSION"   --build-arg NODE_VERSION="$NODE_VERSION"   --build-arg UV_VERSION="$UV_VERSION"   --build-arg GOPLS_VERSION="$GOPLS_VERSION"   --build-arg SERENA_VERSION="$SERENA_VERSION"   --build-arg CODEGRAPH_VERSION="$CODEGRAPH_VERSION"   -t devenv-base:local -f images/base/Dockerfile images/base
```

构建会下载较大的上游工具链并运行其安装脚本。源码构建无需 GHCR 账户、镜像发布权限或已有私有镜像。

### 4. 验证并运行一个程序

```bash
docker run --rm --platform linux/amd64   --entrypoint bash -v "$PWD:/repo:ro"   devenv-base:local /repo/scripts/verify-base.sh /repo/versions/tools.env

docker run --rm --platform linux/amd64 devenv-base:local   sh -c 'printf "package main\nfunc main() { println(42) }\n" > /tmp/hello.go; go run /tmp/hello.go'
```

完成标准：检查脚本输出 `dev-base verification passed`，Go 示例输出 `42`，两次命令均以 0 结束。仅镜像构建或标签计算成功不算完整 Quick Start 验收。

### 5. 常见问题

- **无法连接 Docker：**启动引擎并运行 `docker info`；源码检查无需引擎，构建镜像需要。
- **找不到 `sha256sum`：**安装 GNU coreutils，或使用 Linux Bash 环境。
- **架构检查失败：**当前镜像要求 linux/amd64；未适配并验证所有内置二进制前不能宣称 ARM64 支持。
- **下载/哈希失败：**核对上游地址及 `versions/tools.env` 的版本/校验值，不要绕过校验。
- **挂载目录权限错误：**配置 `DEVENV_RUN_UID`、`DEVENV_RUN_GID`，入口脚本准备私有 home/cache 后降权。
- **GHCR 无权拉取：**源码公开不保证镜像公开；可本地构建，或使用有权访问的镜像。

## 配置说明

共享版本与归档哈希由 [versions/tools.env](versions/tools.env) 维护。项目专用工具留在使用方仓库。运行变量：

| 变量 | 默认值/用途 |
| --- | --- |
| `DEVENV_RUN_UID`、`DEVENV_RUN_GID` | 默认不设置；同时设置后在入口准备完成后切换到对应非 root 用户 |
| `SERENA_HOME` | `/tmp/devenv-home/.serena`，由入口初始化 |
| `GOMODCACHE`、`GOCACHE` | `/cache/go-mod`、`/cache/go-build` |
| `GRADLE_USER_HOME` | Android 镜像中为 `/cache/gradle` |

只挂载需要的项目和缓存路径。不可变 `env-<hash>` 标签由版本和构建输入生成，Android 身份还包含基础镜像哈希。正式使用优先固定核实过的 OCI digest。业务源码变化不要求重建共享工具链。

## 可选功能

### Android 工具链

仅 Android 项目需要，使用前确认并接受适用的 SDK 与 Kotlin LSP 条款。构建基础镜像后，在同一 Bash 会话运行：

```bash
android_args=(--build-arg BASE_IMAGE=devenv-base:local)
for key in GRADLE_VERSION GRADLE_SHA256 KOTLIN_LSP_VERSION KOTLIN_LSP_SHA256 ANDROID_CMDLINE_TOOLS_REVISION ANDROID_CMDLINE_TOOLS_SHA256 ANDROID_PLATFORM ANDROID_BUILD_TOOLS ANDROID_BUILD_TOOLS_COMPAT ANDROID_NDK; do
  android_args+=(--build-arg "$key=${!key}")
done
docker buildx build --load --platform linux/amd64 "${android_args[@]}"   -t devenv-android:local -f images/android/Dockerfile images/android

docker run --rm --platform linux/amd64 --entrypoint bash   -v "$PWD:/repo:ro" devenv-android:local   /repo/scripts/verify-android.sh /repo/versions/tools.env
```

应输出 `dev-android verification passed`。该镜像明显大于基础镜像。非默认 Buildx 驱动无法解析本地基础镜像时，使用默认 Docker 驱动或已授权 registry digest。Android Dockerfile 会执行 SDK 许可接受命令，构建不代表获得再分发许可。

项目挂载与缓存卷均为可选；镜像不管理 gomobile/gobind、项目 TypeScript 工具、媒体引擎或发行打包。

## 开发与验证

```bash
for script in images/base/entrypoint.sh scripts/*.sh; do bash -n "$script"; done
bash scripts/image-tags.sh
```

本项目没有独立应用单元测试套件。现有 CI 检查 Shell 语法、标签及 Dockerfile Buildx 规则；本地构建/运行验收使用上面的 Quick Start。发布默认关闭，只有逐项审核组件许可后才应设置仓库变量 `DEVENV_ALLOW_IMAGE_PUBLISH=true`；不要为文档变更开启发布。获准的发布流程构建两个镜像、运行检查并记录 digest。使用功能分支、PR 与 Squash Merge，Windows/macOS 主机行为与 ARM 模拟仍需单独检查。

## 许可证与合规

构建定义采用 [MIT](LICENSE)，不改变内置工具链、Google Android SDK 或专有 Kotlin LSP 二进制的许可。再分发镜像前查看[第三方声明](THIRD_PARTY_NOTICES.md)。仓库可见性与 GHCR 软件包可见性独立。凭据、浏览器会话、数据库、业务项目和运行缓存不得打入公开镜像层。
