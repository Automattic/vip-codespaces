#!/bin/sh

set -eu
exec 2>&1

export LD_PRELOAD=

# shellcheck disable=SC2154
install -d -D -m 02755 -o "${MARIADB_USER}" -g "${MARIADB_USER}" "${MARIADB_DATADIR}"
chown -R "${MARIADB_USER}:${MARIADB_USER}" "${MARIADB_DATADIR}"

install -d /run/mysqld -o "${MARIADB_USER}" -g "${MARIADB_USER}"

if [ ! -d "${MARIADB_DATADIR}/mysql" ]; then
    mariadb-install-db --auth-root-authentication-method=normal --skip-test-db --user="${MARIADB_USER}" --datadir="${MARIADB_DATADIR}"
fi

# shellcheck disable=SC2086,SC2154 # there could be multiple options in EXTRA_OPTIONS
exec chpst -u "${MARIADB_USER}:${MARIADB_USER}" \
    mariadbd \
        --datadir="${MARIADB_DATADIR}" \
        --sql-mode=ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION \
        --max_allowed_packet=67M \
        --skip_networking=0 \
        --bind-address=127.0.0.1 ${EXTRA_OPTIONS}
