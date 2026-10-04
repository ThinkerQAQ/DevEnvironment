#!/usr/bin/env bash
set -euo pipefail

versions="${1:-/repo/versions/tools.env}"
# shellcheck disable=SC1090
source "$versions"

java -version 2>&1 | head -1 | grep -E '"17(\\.|\")'
gradle --version | grep -F "Gradle ${GRADLE_VERSION}"
test -f "${ANDROID_SDK_ROOT}/platforms/${ANDROID_PLATFORM}/android.jar"
test -d "${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS}"
test -f "${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK}/source.properties"
test "${ANDROID_NDK_HOME}" = "${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK}"
command -v make >/dev/null
command -v sdkmanager >/dev/null

echo "dev-android verification passed"
