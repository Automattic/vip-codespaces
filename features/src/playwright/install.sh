#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
PLAYWRIGHT_VERSION="${VERSION:=latest}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing Playwright...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/playwright
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/playwright/

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive

            if ! hash node >/dev/null 2>&1 || ! hash npm >/dev/null 2>&1 || ! hash npx >/dev/null 2>&1; then
                PACKAGES=""
                if ! hash curl >/dev/null 2>&1; then
                    PACKAGES="${PACKAGES} curl"
                fi

                if ! hash update-ca-certificates >/dev/null 2>&1; then
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
            fi

            npm i -g "playwright-core@${PLAYWRIGHT_VERSION}"
            playwright-core install-deps
            su -s /bin/sh -c 'playwright-core install' "${_REMOTE_USER}"

            update-rc.d -f dbus remove

            apt-get clean
            rm -rf /var/lib/apt/lists/*
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    echo "Done!"
fi
