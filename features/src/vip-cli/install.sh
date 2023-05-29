#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"
: "${VERSION:=latest}"
: "${IMPORT_DB:=false}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing VIP CLI...'
    if ! grep -Eq '^@edgem' /etc/apk/repositories; then
        echo "@edgem https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
    fi

    apk add --no-cache nodejs npm || apk add --no-cache nodejs@edgem npm@edgem
    npm i -g "@automattic/vip@${VERSION}"

    if [ "${IMPORT_DB}" = 'true' ]; then
        install -D -m 0755 -o root -g root import-db.sh /var/lib/wordpress/postinstall.d/40-vip-import-db.sh
    fi

    echo 'Done!'
fi
