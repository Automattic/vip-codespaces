#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Setting up WordPress and Test Library...'

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    WEB_USER="${CONTAINER_USER:-www-data}"
else
    WEB_USER="${_REMOTE_USER}"
fi

install -d -m 0755 -o "${WEB_USER}" -g "${WEB_USER}" /usr/share/wptl
install -m 0755 -o root -g root install-wptl.sh /usr/local/bin/install-wptl

if [ -z "${VERSIONS}" ]; then
    VERSIONS="$(wget https://api.wordpress.org/core/version-check/1.7/ -q -O - | jq -r '[.offers[].version] | unique | map(select( . >= "5.5")) | .[]') nightly"
fi

for version in ${VERSIONS} latest; do
    install-wptl "${version}" &
done
wait

echo 'Done!'
