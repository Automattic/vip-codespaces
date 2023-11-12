#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"
: "${VERSION:=latest}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing VIP CLI...'

    apk add --no-cache nodejs@edgem npm@edgem
    npm i -g "@automattic/vip@${VERSION}"

    install -D -m 0755 -o root -g root import-vip-db.sh /usr/local/bin/import-vip-db

    echo 'Done!'
fi
