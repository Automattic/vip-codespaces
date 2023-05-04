#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${ENABLED:-}" = 'true' ]; then
    echo '(*) Installing Photon...'

    if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
        PHOTON_USER=www-data
    else
        PHOTON_USER="${_REMOTE_USER}"
    fi

    : "${DISABLE_OPTIMIZATIONS:=false}"

    if [ "${DISABLE_OPTIMIZATIONS}" = 'false' ]; then
        apk add --no-cache optipng pngquant libwebp-tools jpegoptim libjpeg-turbo-utils pngcrush
    fi

    install -d -m 0755 -o "${PHOTON_USER}" -g "${PHOTON_USER}" /etc/photon
    install -m 0644 -o "${PHOTON_USER}" -g "${PHOTON_USER}" config.php /etc/photon/config.php

    if [ "${DISABLE_OPTIMIZATIONS}" = 'false' ]; then
        sed -r -i "s@'/usr/bin/[a-z]+'@false@" /etc/photon/config.php
    fi

    install -d -D -m 0755 -o "${PHOTON_USER}" -g "${PHOTON_USER}" /usr/share/webapps/photon
    svn co https://code.svn.wordpress.org/photon/ /usr/share/webapps/photon
    rm -rf /usr/share/webapps/photon/.svn /usr/share/webapps/photon/tests
    chown -R "${PHOTON_USER}:${PHOTON_USER}" /usr/share/webapps/photon

    rm -f /etc/nginx/conf.extra/media-redirect.conf

    if [ -f /etc/conf.d/nginx ]; then
        # shellcheck source=/dev/null
        . /etc/conf.d/nginx
    fi

    : "${MEDIA_REDIRECT_URL:=}"
    php photon.tpl.php "${MEDIA_REDIRECT_URL}" "${ONLY_IMAGES_WITH_QS:-true}" > /etc/nginx/conf.extra/photon.conf

    echo 'Done!'
fi
