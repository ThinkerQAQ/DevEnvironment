# check=skip=InvalidDefaultArgInFrom
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG GRADLE_VERSION
ARG GRADLE_SHA256
ARG ANDROID_CMDLINE_TOOLS_REVISION
ARG ANDROID_CMDLINE_TOOLS_SHA256
ARG ANDROID_PLATFORM
ARG ANDROID_BUILD_TOOLS
ARG ANDROID_NDK

ENV DEBIAN_FRONTEND=noninteractive \
    JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64 \
    ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    GRADLE_HOME=/opt/gradle \
    GRADLE_USER_HOME=/cache/gradle

ENV PATH=${GRADLE_HOME}/bin:${ANDROID_SDK_ROOT}/platform-tools:${ANDROID_SDK_ROOT}/cmdline-tools/${ANDROID_CMDLINE_TOOLS_REVISION}/bin:${PATH}

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        make \
        openjdk-17-jdk-headless \
        pkg-config \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    curl -fsSL "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o /tmp/gradle.zip; \
    echo "${GRADLE_SHA256}  /tmp/gradle.zip" | sha256sum -c -; \
    unzip -q /tmp/gradle.zip -d /opt; \
    ln -s "/opt/gradle-${GRADLE_VERSION}" "${GRADLE_HOME}"; \
    rm /tmp/gradle.zip

RUN set -eux; \
    mkdir -p "${ANDROID_SDK_ROOT}/cmdline-tools"; \
    curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_REVISION}_latest.zip" -o /tmp/android-tools.zip; \
    echo "${ANDROID_CMDLINE_TOOLS_SHA256}  /tmp/android-tools.zip" | sha256sum -c -; \
    unzip -q /tmp/android-tools.zip -d /tmp/android-tools; \
    mv /tmp/android-tools/cmdline-tools "${ANDROID_SDK_ROOT}/cmdline-tools/${ANDROID_CMDLINE_TOOLS_REVISION}"; \
    rm -rf /tmp/android-tools /tmp/android-tools.zip; \
    yes | sdkmanager --licenses >/dev/null || true; \
    sdkmanager \
      "platform-tools" \
      "platforms;${ANDROID_PLATFORM}" \
      "build-tools;${ANDROID_BUILD_TOOLS}" \
      "ndk;${ANDROID_NDK}"

ENV ANDROID_NDK_HOME=/opt/android-sdk/ndk/${ANDROID_NDK}

WORKDIR /workspace
