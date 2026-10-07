#!/bin/sh
set -eu

mkdir -p /cache/go-mod /cache/go-build /cache/gradle /tmp/devenv-home

serena_home="${SERENA_HOME:-/tmp/devenv-home/.serena}"
mkdir -p "${serena_home}"
serena_config="${serena_home}/serena_config.yml"
if [ ! -f "${serena_config}" ]; then
  if [ -n "${DEVENV_KOTLIN_LSP:-}" ]; then
    cat > "${serena_config}" <<EOF
ls_specific_settings:
  kotlin:
    ls_path: "${DEVENV_KOTLIN_LSP}"
projects: []
web_dashboard: false
web_dashboard_open_on_launch: false
EOF
  else
    cat > "${serena_config}" <<EOF
projects: []
web_dashboard: false
web_dashboard_open_on_launch: false
EOF
  fi
fi

if [ -n "${DEVENV_RUN_UID:-}" ] && [ -n "${DEVENV_RUN_GID:-}" ] && [ "${DEVENV_RUN_UID}" != "0" ]; then
  if ! getent group "${DEVENV_RUN_GID}" >/dev/null 2>&1; then
    printf 'devenv:x:%s:\n' "${DEVENV_RUN_GID}" >> /etc/group
  fi
  if ! getent passwd "${DEVENV_RUN_UID}" >/dev/null 2>&1; then
    printf 'devenv:x:%s:%s:Dev Environment:/tmp/devenv-home:/bin/sh\n'       "${DEVENV_RUN_UID}" "${DEVENV_RUN_GID}" >> /etc/passwd
  fi

  ensure_owned() {
    path="$1"
    if [ "$(stat -c '%u:%g' "$path")" != "${DEVENV_RUN_UID}:${DEVENV_RUN_GID}" ]; then
      chown -R "${DEVENV_RUN_UID}:${DEVENV_RUN_GID}" "$path"
    fi
  }

  ensure_owned /cache/go-mod
  ensure_owned /cache/go-build
  ensure_owned /cache/gradle
  chown -R "${DEVENV_RUN_UID}:${DEVENV_RUN_GID}" /tmp/devenv-home

  exec gosu "${DEVENV_RUN_UID}:${DEVENV_RUN_GID}"     env HOME=/tmp/devenv-home "$@"
fi

exec "$@"
