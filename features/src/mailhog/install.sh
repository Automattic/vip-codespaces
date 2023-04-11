#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    MAILHOG_USER=nobody
else
    MAILHOG_USER="${_REMOTE_USER}"
fi

: "${ENABLED:=}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing MailHog...'

    if [ -f /usr/local/bin/mailpit ]; then
        echo '(!) MailHog cannot be installed along with Mailpit.'
        exit 1
    fi

    ARCH="$(arch)"
    if [ "${ARCH}" = "arm64" ] || [ "${ARCH}" = "aarch64" ]; then
        ARCH="arm"
    elif [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then
        ARCH="amd64"
    else
        echo "(!) Unsupported architecture: ${ARCH}"
        exit 1
    fi

    wget -q "https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_${ARCH}" -O /usr/local/bin/mailhog

    : "${PHP_INI_DIR:=/etc/php}":

    chmod 0755 /usr/local/bin/mailhog
    install -m 0644 php-mailhog.ini "${PHP_INI_DIR}/conf.d/mailhog.ini"

    install -D -m 0755 -o root -g root service-run /etc/sv/mailhog/run
    install -d -m 0755 -o root -g root /etc/service
    ln -sf /etc/sv/mailhog /etc/service/mailhog

    export MAILHOG_USER
    # shellcheck disable=SC2016
    envsubst '$MAILHOG_USER' < conf-mailhog.tpl > /etc/conf.d/mailhog

    echo 'Done!'
fi
