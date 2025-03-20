#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${NIGHTLY:=}"

echo '(*) Installing wp-cli...'

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/wp-cli
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/wp-cli/

if [ "${NIGHTLY}" = "true" ]; then
    url="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-nightly.phar"
else
    url="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
fi

PACKAGES=""
if ! hash curl >/dev/null 2>&1; then
    PACKAGES="${PACKAGES} curl"
fi

if ! hash update-ca-certificates >/dev/null 2>&1; then
    PACKAGES="${PACKAGES} ca-certificates"
fi

if [ -n "${PACKAGES}" ]; then
    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}
            apt-get clean
            rm -rf /var/lib/apt/lists/*
        ;;

        "alpine")
            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac
fi

curl -sSL "${url}" -o /usr/local/bin/wp
chmod 0755 /usr/local/bin/wp
echo 'Done!'
