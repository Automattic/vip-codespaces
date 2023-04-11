#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    USER=nginx
else
    USER="${_REMOTE_USER}"
fi

: "${NIGHTLY:=}"

echo '(*) Installing wp-cli...'
if [ "${NIGHTLY}" = "true" ]; then
    url="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli-nightly.phar"
else
    url="https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"
fi

wget -q "${url}" -O /usr/local/bin/wp
chmod 0755 /usr/local/bin/wp

if [ -n "$(command -v php || true)" ]; then
    sudo -u "${USER}" wp cli info || true
fi

echo 'Done!'
