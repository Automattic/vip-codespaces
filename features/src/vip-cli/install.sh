#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"
VIP_CLI_VERSION="${VERSION:-latest}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing VIP CLI...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/vip-cli
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/vip-cli/

    if ! hash node > /dev/null 2>&1 || ! hash npm > /dev/null 2>&1; then
        # shellcheck source=/dev/null
        . /etc/os-release

        : "${ID:=}"
        : "${ID_LIKE:=${ID}}"

        case "${ID_LIKE}" in
            "debian")
                export DEBIAN_FRONTEND=noninteractive
                PACKAGES=""
                if ! hash curl > /dev/null 2>&1; then
                    PACKAGES="${PACKAGES} curl"
                fi

                if ! hash update-ca-certificates > /dev/null 2>&1; then
                    PACKAGES="${PACKAGES} ca-certificates"
                fi

                if [ -n "${PACKAGES}" ]; then
                    apt-get update
                    # shellcheck disable=SC2086
                    apt-get install -y --no-install-recommends ${PACKAGES}
                fi

                curl -fsSL https://deb.nodesource.com/setup_lts.x -o nodesource_setup.sh
                chmod +x nodesource_setup.sh
                ./nodesource_setup.sh
                apt-get install -y nodejs

                apt-get clean
                rm -rf /var/lib/apt/lists/*
                ;;

            "alpine")
                apk add --no-cache nodejs npm
                ;;

            *)
                echo "(!) Unsupported distribution: ${ID}"
                exit 1
                ;;
        esac
    fi

    CLEAN=""
    if ! hash g++ > /dev/null 2>&1; then
        # shellcheck source=/dev/null
        . /etc/os-release

        : "${ID:=}"
        : "${ID_LIKE:=${ID}}"

        case "${ID_LIKE}" in
            "debian")
                export DEBIAN_FRONTEND=noninteractive
                apt-get update
                apt-get install -y --no-install-recommends g++ make
                CLEAN=1
                ;;

            "alpine")
                apk add --no-cache g++ make
                CLEAN=1
                ;;

            *)
                echo "(!) Unsupported distribution: ${ID}"
                exit 1
                ;;
        esac
    fi

    npm i -g "@automattic/vip@${VIP_CLI_VERSION}"

    install -D -m 0755 -o root -g root vip-sync-db.sh /usr/local/bin/vip-sync-db

    if [ -n "${CLEAN}" ]; then
        # shellcheck source=/dev/null
        . /etc/os-release
        : "${ID:=}"
        : "${ID_LIKE:=${ID}}"

        if [ "${ID_LIKE}" = "debian" ]; then
            apt-get remove -y --purge g++ make
            apt-get clean
            rm -rf /var/lib/apt/lists/*
        elif [ "${ID_LIKE}" = "alpine" ]; then
            apk del --no-cache g++ make
        fi
    fi

    echo 'Done!'
fi
