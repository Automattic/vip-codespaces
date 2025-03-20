#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing MariaDB...'

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${INSTALLDATABASETOWORKSPACES:=}"
: "${INSTALL_RUNIT_SERVICE:=true}"
: "${EXTRA_OPTIONS:=""}"

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/mariadb
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/mariadb/

if [ "${_REMOTE_USER}" = "root" ]; then
    MARIADB_USER=mysql
    INSTALLDATABASETOWORKSPACES=false

    echo '(!) Cannot install databases to the workspace when remoteUser is root.'
else
    MARIADB_USER="${_REMOTE_USER}"
fi

if [ "${INSTALLDATABASETOWORKSPACES}" != 'true' ]; then
    MARIADB_DATADIR=/var/lib/mysql
else
    MARIADB_DATADIR=/workspaces/mysql-data
    install -d -D -m 02755 -o "${MARIADB_USER}" -g "${MARIADB_USER}" "${MARIADB_DATADIR}"
fi

# shellcheck source=/dev/null
. /etc/os-release
: "${ID:=}"
: "${ID_LIKE:=${ID}}"
ENTRYPOINT=""

case "${ID_LIKE}" in
    "debian")
        export DEBIAN_FRONTEND=noninteractive
        PACKAGES="mariadb-client mariadb-server"
        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        apt-get update
        # shellcheck disable=SC2086
        apt-get install -y --no-install-recommends ${PACKAGES}
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        update-rc.d -f mariadb remove
        update-rc.d -f rsync remove

        if [ "${INSTALLDATABASETOWORKSPACES}" = 'true' ]; then
            mv /var/lib/mysql/debian-*.flag "${MARIADB_DATADIR}"
        else
            # The init script will recreate the database with the correct authentication method
            rm -rf /var/lib/mysql/mysql
            rm -f /var/lib/mysql/aria_log* /var/lib/mysql/ib*
        fi

        ENTRYPOINT="entrypoint.deb.tpl"
    ;;

    "alpine")
        PACKAGES="mariadb-client mariadb"
        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        if [ ! -x /sbin/chpst ] && [ ! -x /sbin/su-exec ]; then
            PACKAGES="${PACKAGES} su-exec"
        fi

        # shellcheck disable=SC2086
        apk add --no-cache ${PACKAGES}

        ENTRYPOINT="entrypoint.alpine.tpl"
    ;;

    *)
        echo "(!) Unsupported distribution: ${ID}"
        exit 1
    ;;
esac

if [ "${INSTALLDATABASETOWORKSPACES}" = 'true' ]; then
    usermod -d /workspaces/mysql mysql
    rm -rf /var/lib/mysql
fi

export MARIADB_USER
export MARIADB_DATADIR
export EXTRA_OPTIONS

if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
    install -D -d -m 0755 -o root -g root /etc/service /etc/sv/mariadb
    # shellcheck disable=SC2016
    envsubst '$MARIADB_USER $MARIADB_DATADIR $EXTRA_OPTIONS' < service-run.tpl > /etc/sv/mariadb/run && chmod 0755 /etc/sv/mariadb/run
    ln -sf /etc/sv/mariadb /etc/service/mariadb
fi

if [ -d /var/lib/entrypoint.d ]; then
    # shellcheck disable=SC2016
    envsubst '$MARIADB_USER $MARIADB_DATADIR $EXTRA_OPTIONS' < "${ENTRYPOINT}" > /var/lib/entrypoint.d/50-mariadb
    chmod 0755 /var/lib/entrypoint.d/50-mariadb
fi

echo 'Done!'
