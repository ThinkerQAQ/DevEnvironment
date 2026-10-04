#!/bin/sh
set -eu

mkdir -p /cache/go-mod /cache/go-build /cache/gradle /tmp/devenv-home

if [ -n "${DEVENV_RUN_UID:-}" ] && [ -n "${DEVENV_RUN_GID:-}" ] && [ "${DEVENV_RUN_UID}" != "0" ]; then
  chown -R "${DEVENV_RUN_UID}:${DEVENV_RUN_GID}" /cache /tmp/devenv-home
  exec gosu "${DEVENV_RUN_UID}:${DEVENV_RUN_GID}" "$@"
fi

exec "$@"
