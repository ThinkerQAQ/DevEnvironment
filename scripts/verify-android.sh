#!/usr/bin/env bash
set -euo pipefail

versions="${1:-/repo/versions/tools.env}"
# shellcheck disable=SC1090
source "$versions"

java_version="$(java -version 2>&1)"
printf '%s\n' "$java_version"
grep -qE 'version "17([.\"]|$)' <<<"$java_version"

gradle_version="$(gradle --version)"
printf '%s\n' "$gradle_version"
grep -qF "Gradle ${GRADLE_VERSION}" <<<"$gradle_version"

platform_jar="${ANDROID_SDK_ROOT}/platforms/${ANDROID_PLATFORM}/android.jar"
build_tools_dir="${ANDROID_SDK_ROOT}/build-tools/${ANDROID_BUILD_TOOLS}"
ndk_properties="${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK}/source.properties"

test -f "$platform_jar"
echo "Android platform: $platform_jar"
test -d "$build_tools_dir"
echo "Android build tools: $build_tools_dir"
test -f "$ndk_properties"
echo "Android NDK: $ndk_properties"
test "${ANDROID_NDK_HOME}" = "${ANDROID_SDK_ROOT}/ndk/${ANDROID_NDK}"
echo "ANDROID_NDK_HOME: ${ANDROID_NDK_HOME}"
command -v make
command -v sdkmanager

echo "dev-android verification passed"
