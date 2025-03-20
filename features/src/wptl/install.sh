#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
WPTL_VERSION="${VERSION:=}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing WordPress Test Library...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/wptl
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/wptl/

    PACKAGES=""
    if ! hash svn >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} subversion"
    fi

    if ! hash unzip >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} unzip"
    fi

    if ! hash jq >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} jq"
    fi

    if ! hash curl >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} curl"
    fi

    if ! hash update-ca-certificates >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} ca-certificates"
    fi

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            if ! hash su >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} util-linux"
            fi

            if [ -n "${PACKAGES}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
                apt-get clean
                rm -rf /var/lib/apt/lists/*
            fi
        ;;

        "alpine")
            if ! hash su >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} util-linux-login"
            fi

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

    install -d -D -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /usr/src/wordpress
    install -m 0755 -o root -g root setup-wptl use-wptl /usr/local/bin/

    for ver in ${WPTL_VERSION}; do
        echo "Installing WordPress Test Library ${ver}..."
        su -s /bin/sh -c "setup-wptl ${ver}" "${_REMOTE_USER}"
    done

    echo 'Done!'
fi
