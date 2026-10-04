#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$root"

base_hash="$({
  sha256sum versions/tools.env
  sha256sum images/base/Dockerfile
  sha256sum images/base/entrypoint.sh
} | sha256sum | cut -c1-12)"

android_hash="$({
  printf 'base=%s\n' "$base_hash"
  sha256sum versions/tools.env
  sha256sum images/android/Dockerfile
} | sha256sum | cut -c1-12)"

printf 'BASE_TAG=env-%s\n' "$base_hash"
printf 'ANDROID_TAG=env-%s\n' "$android_hash"
