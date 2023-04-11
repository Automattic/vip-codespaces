#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"
: "${RETAINGIT:=}"

if [ "${ENABLED}" != "false" ]; then
    echo '(*) Installing VIP Go mu-plugins...'

    if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
        WEB_USER=www-data
    else
        WEB_USER="${_REMOTE_USER}"
    fi

    git clone --depth=1 https://github.com/Automattic/vip-go-mu-plugins-built.git /wp/wp-content/mu-plugins
    if [ "${RETAINGIT}" != "true" ]; then
        rm -rf /wp/wp-content/mu-plugins/.git
    fi

    chown -R "${WEB_USER}:${WEB_USER}" /wp/wp-content/mu-plugins
    echo 'Done!'
fi
