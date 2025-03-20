#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing su-exec...'

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/su-exec
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/su-exec/

# shellcheck source=/dev/null
. /etc/os-release

: "${ID:=}"
: "${ID_LIKE:=${ID}}"

if [ -z "${ID}" ]; then
    echo 'Unable to determine the distribution.'
    exit 1
fi

case "${ID_LIKE}" in
    "debian")
        export DEBIAN_FRONTEND=noninteractive
        PACKAGES=""
        if ! dpkg -s libc6-dev >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} libc6-dev"
        fi

        if ! hash cc >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} tcc"
        fi

        if [ -n "${PACKAGES}" ]; then
            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}
        fi

        cc -O2 su-exec.c -o /usr/local/bin/su-exec

        if [ -n "${PACKAGES}" ]; then
            # shellcheck disable=SC2086
            apt-get purge -y --auto-remove ${PACKAGES}
            apt-get clean
            rm -rf /var/lib/apt/lists/*
        fi
    ;;

    "alpine")
        apk add --no-cache su-exec
    ;;

    *)
        echo "(!) Unsupported distribution: ${ID}"
        exit 1
    ;;
esac

echo 'Done!'
