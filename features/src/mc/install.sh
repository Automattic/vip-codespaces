#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${ENABLED:-}" = "true" ]; then
    echo '(*) Installing Midnight Commander...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/mc
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/mc/

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y --no-install-recommends mc
            apt-get clean
            rm -rf /var/lib/apt/lists/*
        ;;

        "alpine")
            apk add --no-cache mc
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
    esac

    echo 'Done!'
fi
