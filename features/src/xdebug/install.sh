#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

get_php_version() {
    if [ -f /etc/dev-env-features/php ]; then
        cat /etc/dev-env-features/php
    else
        php -r 'echo PHP_MAJOR_VERSION, ".", PHP_MINOR_VERSION;'
    fi
}

xdebug_81_alpine() {
    alpine_version="$(cat /etc/alpine-release)"
    if [ "$(printf '%s\n' "3.20" "${alpine_version}" | sort -V | head -n1 || true)" = "3.20" ]; then
        REPOS="-X https://dl-cdn.alpinelinux.org/alpine/v3.19/main -X https://dl-cdn.alpinelinux.org/alpine/v3.19/community"
    else
        REPOS=""
    fi

    # shellcheck disable=SC2086 # We need to expand $REPOS
    apk add --no-cache php81-pecl-xdebug ${REPOS}
    rm -f /etc/php81/conf.d/50_xdebug.ini
}

xdebug_82_alpine() {
    apk add --no-cache php82-pecl-xdebug
    rm -f /etc/php81/conf.d/50_xdebug.ini
}

xdebug_83_alpine() {
    apk add --no-cache php83-pecl-xdebug
    rm -f /etc/php81/conf.d/50_xdebug.ini
}

xdebug_84_alpine() {
    alpine_version="$(cat /etc/alpine-release)"
    if [ "$(printf '%s\n' "3.21" "${alpine_version}" | sort -V | head -n1 || true)" = "3.21" ]; then
        REPOS=""
    else
        REPOS="-X https://dl-cdn.alpinelinux.org/alpine/v3.21/community"
    fi

    # shellcheck disable=SC2086 # We need to expand $REPOS
    apk add --no-cache php84-pecl-xdebug ${REPOS}
    rm -f /etc/php81/conf.d/50_xdebug.ini
}

xdebug_81_deb() {
    apt-get install -y --no-install-recommends php8.1-xdebug
}

xdebug_82_deb() {
    apt-get install -y --no-install-recommends php8.2-xdebug
}

xdebug_83_deb() {
    apt-get install -y --no-install-recommends php8.3-xdebug
}

xdebug_84_deb() {
    apt-get install -y --no-install-recommends php8.4-xdebug
}

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"
: "${MODE:=debug}"

if [ "${ENABLED}" != "true" ]; then
    MODE=off
fi

echo '(*) Installing Xdebug...'

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/xdebug
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/xdebug/

# shellcheck source=/dev/null
. /etc/os-release

: "${ID:=}"
: "${ID_LIKE:=${ID}}"

PHP_VERSION=$(get_php_version)
PHP_INI_DIR=
NEED_ENMOD=
SUFFIX=

case "${ID_LIKE}" in
    debian)
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        case "${PHP_VERSION}" in
            8.1)
                xdebug_81_deb
            ;;
            8.2)
                xdebug_82_deb
            ;;
            8.3)
                xdebug_83_deb
            ;;
            8.4)
                xdebug_84_deb
            ;;
            *)
                echo "(!) Unsupported PHP version: ${PHP_VERSION}"
                exit 1
            ;;
        esac
        PHP_INI_DIR="/etc/php/${PHP_VERSION}/mods-available"
        NEED_ENMOD=1
        SUFFIX=.debian
        apt-get clean
        rm -rf /var/lib/apt/lists/*
    ;;

    alpine)
        case "${PHP_VERSION}" in
            8.1)
                xdebug_81_alpine
            ;;
            8.2)
                xdebug_82_alpine
            ;;
            8.3)
                xdebug_83_alpine
            ;;
            8.4)
                xdebug_84_alpine
            ;;
            *)
                echo "(!) Unsupported PHP version: ${PHP_VERSION}"
                exit 1
            ;;
        esac
        VER="$(echo "${PHP_VERSION}" | tr -d '.')"
        PHP_INI_DIR="/etc/php${VER}/conf.d"
        SUFFIX=.alpine
    ;;

    *)
        echo "(!) Unsupported distribution: ${ID_LIKE}"
        exit 1
    ;;
esac

sed "s/^xdebug\\.mode.*\$/xdebug.mode = \"${MODE}\"/" xdebug.ini > "${PHP_INI_DIR}/xdebug.ini"
if [ -n "${NEED_ENMOD}" ]; then
    phpenmod -v "${PHP_VERSION}" xdebug
fi

install -m 0755 xdebug-disable /usr/local/bin
install -m 0755 "xdebug-set-mode${SUFFIX}" /usr/local/bin/xdebug-set-mode

echo 'Done!'
