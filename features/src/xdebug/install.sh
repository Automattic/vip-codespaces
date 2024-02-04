#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

xdebug_81() {
    apk add --no-cache php81-pecl-xdebug
}

xdebug_82() {
    apk add --no-cache php82-pecl-xdebug
}

xdebug_83() {
    apk add --no-cache php83-pecl-xdebug
}

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing Xdebug...'
    : MODE="${MODE:-debug}"
    if [ -f /etc/profile.d/php_ini_dir.sh ]; then
        # shellcheck source=/dev/null
        . /etc/profile.d/php_ini_dir.sh
    fi
    DIR=${PHP_INI_DIR:-/etc/php}

    if [ ! -d "${DIR}/conf.d" ]; then
        echo "(!) Unable to find out PHP configuration directory."
        exit 1
    fi

    if [ ! -f /etc/dev-env-features/php ]; then
        if apk list --installed php8 2>/dev/null; then
            version="8.0"
        elif apk list --installed php81 2>/dev/null; then
            version="8.1"
        elif apk list --installed php82 2>/dev/null; then
            version="8.2"
        elif apk list --installed php83 2>/dev/null; then
            version="8.3"
        else
            echo "(!) Unable to find out PHP version."
            exit 1
        fi
    else
        version=$(cat /etc/dev-env-features/php)
    fi

    case "${version}" in
        8.0|8.1)
            xdebug_81
        ;;
        8.2)
            xdebug_82
        ;;
        8.3)
            xdebug_83
        ;;
        *)
            echo "(!) Unsupported PHP version: ${version}"
            exit 1
        ;;
    esac

    sed "s/^xdebug\\.mode.*\$/xdebug.mode = ${MODE}/" xdebug.ini > "${DIR}/conf.d/xdebug.ini"
    install -m 0755 xdebug-disable xdebug-set-mode /usr/local/bin

    echo 'Done!'
fi
