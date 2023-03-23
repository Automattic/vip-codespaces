#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    MAILHOG_USER=nobody
else
    MAILHOG_USER="${_REMOTE_USER}"
fi

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing MailHog...'

    if [ "$(arch)" = "arm64" ]; then
        wget -q https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_arm -O /usr/local/bin/mailhog
    elif [ "$(arch)" = "x86_64" ]; then
        wget -q https://github.com/mailhog/MailHog/releases/download/v1.0.0/MailHog_linux_amd64 -O /usr/local/bin/mailhog
    else
        echo "(!) Unsupported architecture: $(arch)"
        exit 1
    fi

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
