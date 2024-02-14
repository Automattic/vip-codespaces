#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing su-exec...'

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
        PACKAGES=""
        if ! dpkg -s libc6-dev >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} libc6-dev"
        fi

        if ! hash cc >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} tcc"
        fi

        if ! hash wget >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} wget"
        fi

        if ! hash update-ca-certificates >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} ca-certificates"
        fi

        if [ -n "${PACKAGES}" ]; then
            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}
        fi

        wget -q https://raw.githubusercontent.com/ncopa/su-exec/master/su-exec.c -O su-exec.c
        cc -O2 su-exec.c -o /usr/local/bin/su-exec
        rm su-exec.c

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
