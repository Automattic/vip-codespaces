#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
: "${BRANCH:=staging}"
: "${DEVELOPMENT_MODE:=false}"

if [ "${ENABLED}" != "false" ]; then
    echo '(*) Installing VIP Go mu-plugins...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/vip-go-mu-plugins
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/vip-go-mu-plugins/

    PACKAGES=""
    if ! hash git >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} git"
    fi

    if ! hash update-ca-certificates >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} ca-certificates"
    fi

    if ! hash rsync >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} rsync"
    fi

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            if [ -n "${PACKAGES}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
                update-rc.d -f rsync remove
                apt-get clean
                rm -rf /var/lib/apt/lists/*
            fi
        ;;

        "alpine")
            if [ -n "${PACKAGES}" ]; then
                # shellcheck disable=SC2086
                apk add --no-cache ${PACKAGES}
            fi
        ;;

        *)
            echo "Unsupported distribution: ${ID_LIKE}"
            exit 1
        ;;
    esac

    install -D -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /wp/wp-content/mu-plugins
    install -d -m 0755 -o root -g root /etc/vip-go-mu-plugins
    install -m 0755 -o root -g root update-mu-plugins /usr/local/bin/update-mu-plugins

    touch /etc/vip-go-mu-plugins/.rsyncignore

    update-mu-plugins "${BRANCH}" "${DEVELOPMENT_MODE}"
    echo 'Done!'
fi
