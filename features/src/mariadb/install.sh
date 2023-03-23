#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing MariaDB...'

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    MARIADB_USER=mysql
else
    MARIADB_USER="${_REMOTE_USER}"
fi

apk add --no-cache mariadb-client mariadb

if [ "${INSTALLDATABASETOWORKSPACES}" != 'true' ]; then
    MARIADB_DATADIR=/var/lib/mysql
else
    MARIADB_DATADIR=/workspaces/mysql-data
    usermod -d /workspaces/mysql mysql
    rm -rf /var/lib/mysql
fi

install -D -m 0755 -o root -g root service-run /etc/sv/mariadb/run
install -d -m 0755 -o root -g root /etc/service
ln -sf /etc/sv/mariadb /etc/service/mariadb

export MARIADB_USER
export MARIADB_DATADIR
# shellcheck disable=SC2016
envsubst '$MARIADB_USER $MARIADB_DATADIR' < conf-mariadb.tpl > /etc/conf.d/mariadb

echo 'Done!'
