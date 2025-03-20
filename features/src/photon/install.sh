#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=false}"
: "${DISABLE_OPTIMIZATIONS:=true}"
: "${ONLY_IMAGES_WITH_QS:=true}"

if [ "${ENABLED}" = 'true' ]; then
    echo '(*) Installing Photon...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/photon
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/photon/

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    PACKAGES=""
    if ! hash svn >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} subversion"
    fi

    if ! hash update-ca-certificates >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} ca-certificates"
    fi

    if [ "${DISABLE_OPTIMIZATIONS}" = 'false' ]; then
        if ! hash optipng >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} optipng"
        fi

        if ! hash pngquant >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} pngquant"
        fi

        if ! hash jpegoptim >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} jpegoptim"
        fi

        if ! hash jpegoptim >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} pngcrush"
        fi
    fi

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            if [ "${DISABLE_OPTIMIZATIONS}" = 'false' ]; then
                if ! hash cwebp >/dev/null 2>&1; then
                    PACKAGES="${PACKAGES} webp"
                fi

                if ! hash cjpeg >/dev/null 2>&1; then
                    PACKAGES="${PACKAGES} libjpeg-turbo-progs"
                fi
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
            if [ "${DISABLE_OPTIMIZATIONS}" = 'false' ]; then
                if ! hash cwebp >/dev/null 2>&1; then
                    PACKAGES="${PACKAGES} libwebp-tools"
                fi

                if ! hash cjpeg >/dev/null 2>&1; then
                    PACKAGES="${PACKAGES} libjpeg-turbo-utils"
                fi
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


    install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /etc/photon
    install -m 0644 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" config.php /etc/photon/config.php

    if [ "${DISABLE_OPTIMIZATIONS}" != 'false' ]; then
        sed -r -i "s@'/usr/bin/[a-z]+'@false@" /etc/photon/config.php
    fi

    install -d -D -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /usr/share/webapps/photon
    svn co https://code.svn.wordpress.org/photon/ /usr/share/webapps/photon
    rm -rf /usr/share/webapps/photon/.svn /usr/share/webapps/photon/tests
    chown -R "${_REMOTE_USER}:${_REMOTE_USER}" /usr/share/webapps/photon
    ln -s /etc/photon/config.php /usr/share/webapps/photon/config.php

    if [ -d /etc/nginx/conf.extra ]; then
        rm -f /etc/nginx/conf.extra/media-redirect.conf

        if [ -f /etc/conf.d/nginx ]; then
            # shellcheck source=/dev/null
            . /etc/conf.d/nginx
        fi

        : "${MEDIA_REDIRECT_URL:=}"
        php photon.tpl.php "${MEDIA_REDIRECT_URL}" "${ONLY_IMAGES_WITH_QS}" > /etc/nginx/conf.extra/photon.conf
    fi

    echo 'Done!'
fi
