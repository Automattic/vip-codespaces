#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${ENABLED:-}" = 'true' ]; then
    echo '(*) Installing cron...'
    apk add --no-cache busybox-suid

    install -D -m 0755 -o root -g root service-run /etc/sv/cron/run
    install -d -m 0755 -o root -g root /etc/service
    ln -sf /etc/sv/cron /etc/service/cron

    if [ "${RUN_WP_CRON:-}" = 'true' ] && [ -n "${WP_CRON_SCHEDULE:-}" ]; then
        if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
            WEB_USER=www-data
        else
            WEB_USER="${_REMOTE_USER}"
        fi

        echo "${WP_CRON_SCHEDULE} [ -x /usr/local/bin/wp ] && /usr/local/bin/wp cron event run --due-now" | crontab -u "${WEB_USER}" -
    fi

    echo 'Done!'
fi
