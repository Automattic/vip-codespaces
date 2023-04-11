#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    WEB_USER=www-data
else
    WEB_USER="${_REMOTE_USER}"
fi

echo '(*) Installing Dev Tools...'

install -d -D -m 0755 -o "${WEB_USER}" -g "${WEB_USER}" /wp/wp-content/mu-plugins
install -m 0644 -o "${WEB_USER}" -g "${WEB_USER}" dev-env-plugin.php /wp/wp-content/mu-plugins/dev-env-plugin.php

echo 'Done!'
