#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=true}"
: "${FPM_SOCKET=/var/run/php-fpm.sock}"
: "${WORDPRESS_PATH:=/wp}"
: "${WP_CLI_PATH=/usr/local/bin/wp}"
: "${INSTALL_RUNIT_SERVICE:=true}"


if [ "${ENABLED}" = 'true' ]; then
    echo '(*) Installing Cron Control Runner...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/cron-control-runner
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/cron-control-runner/

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            PACKAGES=""
            if ! hash curl >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} curl"
            fi

            if ! hash update-ca-certificates >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} ca-certificates"
            fi

            if ! hash envsubst >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} gettext"
            fi

            if [ -n "${PACKAGES}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
            fi

            apt-get clean
            rm -rf /var/lib/apt/lists/*
        ;;

        "alpine")
            PACKAGES=""
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
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    ARCH="$(arch)"
    LATEST=$(curl -w '%{url_effective}' -ILsS https://github.com/Automattic/cron-control-runner/releases/latest -o /dev/null | sed -e 's|^.*/||')
    if [ "${ARCH}" = "arm64" ] || [ "${ARCH}" = "aarch64" ]; then
        ARCH="arm64"
    elif [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then
        ARCH="amd64"
    else
        echo "(!) Unsupported architecture: ${ARCH}"
        exit 1
    fi
    curl -SL "https://github.com/Automattic/cron-control-runner/releases/download/${LATEST}/cron-control-runner-linux-${ARCH}" -o /usr/local/bin/cron-control-runner
    chmod 0755 /usr/local/bin/cron-control-runner

    if [ -z "${WP_CLI_PATH}" ] || [ ! -f "${WP_CLI_PATH}" ]; then
        curl -SLo /usr/local/bin/wp.phar https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
        install -m 0755 -o root -g root /usr/local/bin/wp.phar /usr/local/bin/wp
        WP_CLI_PATH=/usr/local/bin/wp
    else
        ln -sf "${WP_CLI_PATH}" /usr/local/bin/wp.phar
    fi

    if [ -n "${FPM_SOCKET}" ]; then
        install -D -m 0644 -o root -g root fpm-cron-runner.php /var/wpvip/fpm-cron-runner.php
    fi

    if [ -d /var/lib/entrypoint.d ]; then
        export FPM_SOCKET WORDPRESS_PATH WP_CLI_PATH
        # shellcheck disable=SC2016
        envsubst '$FPM_SOCKET $WORDPRESS_PATH $WP_CLI_PATH' < entrypoint.tpl > /var/lib/entrypoint.d/50-cron-control-runner
        chmod 0755 /var/lib/entrypoint.d/50-cron-control-runner
    fi

    if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
        install -D -d -m 0755 -o root -g root /etc/service /etc/sv/cron-control-runner
        export FPM_SOCKET WORDPRESS_PATH WP_CLI_PATH
        # shellcheck disable=SC2016
        envsubst '$FPM_SOCKET $WORDPRESS_PATH $WP_CLI_PATH $_REMOTE_USER' < service-run.tpl > /etc/sv/cron-control-runner/run
        chmod 0755 /etc/sv/cron-control-runner/run
        ln -sf /etc/sv/cron-control-runner /etc/service/cron-control-runner
    fi
fi
