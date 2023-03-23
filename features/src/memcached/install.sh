#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing memcached...'

    if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
        PHP_USER="www-data"
    else
        PHP_USER="${_REMOTE_USER}"
    fi

    apk add --no-cache php8-pecl-memcache php8-pecl-memcached memcached
    install -D -m 0755 -o root -g root service-run /etc/sv/memcached/run
    install -d -m 0755 -o root -g root /etc/service
    install -d -m 0755 -o "${PHP_USER}" -g "${PHP_USER}" /wp
    install -d -m 0755 -o "${PHP_USER}" -g "${PHP_USER}" /wp/wp-content
    install -m 0644 -o "${PHP_USER}" -g "${PHP_USER}" object-cache.php object-cache-stable.php object-cache-next.php /wp/wp-content/
    ln -sf /etc/sv/memcached /etc/service/memcached
    echo 'Done!'
fi
