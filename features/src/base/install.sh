#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin
export LD_PRELOAD=

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"

HOME_DIR="$(getent passwd "${_REMOTE_USER}" | cut -d: -f6)"

install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.local"
install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.local/share"
install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.local/share/vip-codespaces"
install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.local/share/vip-codespaces/login"

install -m 0644 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" .bashrc "${HOME_DIR}/.bashrc"
install -m 0644 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" 001-welcome.sh "${HOME_DIR}/.local/share/vip-codespaces/login/001-welcome.sh"

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/base
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/base/

# shellcheck source=/dev/null
. /etc/os-release

: "${ID:=}"
: "${ID_LIKE:=${ID}}"

PACKAGES=""
ARCH="$(arch)"
case "${ID_LIKE}" in
    "debian")
        export DEBIAN_FRONTEND=noninteractive
        PACKAGES=""
        if ! hash eatmydata >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} eatmydata"
        fi

        if ! hash curl >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} curl"
        fi

        if ! hash update-ca-certificates >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} ca-certificates"
        fi

        if ! hash gpg >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gnupg2"
        fi

        if ! hash lsb_release >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} lsb-release"
        fi

        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        if [ -n "${PACKAGES}" ]; then
            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}
        fi

        mkdir -p /usr/lib/libeatmydata
        ln -sf -t /usr/lib/libeatmydata/ "/usr/lib/${ARCH}-linux-gnu/libeatmydata.so"*
    ;;

    "alpine")
        if ! hash eatmydata >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} libeatmydata"
        fi

        if ! hash curl >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} curl"
        fi

        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        if [ -n "${PACKAGES}" ]; then
            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}
        fi

        mkdir -p /usr/lib/libeatmydata
        ln -sf /usr/lib/libeatmydata.so /usr/lib/libeatmydata/libeatmydata.so
    ;;

    *)
        echo "Unsupported distribution: ${ID_LIKE}"
        exit 1
    ;;
esac
