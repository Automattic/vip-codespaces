#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${NIGHTLY:=}"

echo '(*) Installing wp-cli...'

if [ "${NIGHTLY}" = "true" ]; then
    url="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-nightly.phar"
else
    url="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
fi

if ! hash wget >/dev/null 2>&1; then
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    if [ -z "${ID}" ]; then
        echo 'Unable to determine the distribution.'
        exit 1
    fi

    case "${ID_LIKE}" in
        "debian")
            PACKAGES="wget"
            if ! hash update-ca-certificates >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} ca-certificates"
            fi

            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}

            wget -q "${url}" -O /usr/local/bin/wp

            # shellcheck disable=SC2086
            apt-get purge -y --auto-remove ${PACKAGES}
            apt-get clean
            rm -rf /var/lib/apt/lists/*
        ;;

        "alpine")
            PACKAGES="wget"
            if ! hash update-ca-certificates >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} ca-certificates"
            fi

            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}

            wget -q "${url}" -O /usr/local/bin/wp

            # shellcheck disable=SC2086
            apk del --no-cache ${PACKAGES}
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac
else
    wget -q "${url}" -O /usr/local/bin/wp
fi

chmod 0755 /usr/local/bin/wp
echo 'Done!'
