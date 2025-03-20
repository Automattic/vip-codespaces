#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=true}"
: "${INSTALL_RUNIT_SERVICE:=true}"

if [ "${ENABLED}" = 'true' ]; then
    echo '(*) Installing cron...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/cron
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/cron/

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            # In Ubuntu Noble, cron now depends on systemd. We need to install busybox-static and use it as crond/crontab to avoid garbage in the system.
            PACKAGES_NOREMOVE=""
            PACKAGES=""
            if [ ! -f /usr/bin/busybox ]; then
                PACKAGES_NOREMOVE="${PACKAGES_NOREMOVE} busybox-static"
            fi

            if ! dpkg -s libc6-dev >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} libc6-dev"
            fi

            if ! hash cc >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} tcc"
            fi

            if [ -n "${PACKAGES}" ] || [ -n "${PACKAGES_NOREMOVE}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES} ${PACKAGES_NOREMOVE}
            fi

            cc -O2 bbsuid.c -o /usr/local/bin/bbsuid

            if [ -n "${PACKAGES}" ]; then
                # shellcheck disable=SC2086
                apt-get purge -y --auto-remove ${PACKAGES}
            fi

            apt-get clean
            rm -rf /var/lib/apt/lists/*

            chown root:root /usr/local/bin/bbsuid
            chmod 04111 /usr/local/bin/bbsuid
            ln -s /usr/local/bin/bbsuid /usr/bin/crontab
            ln -s /usr/bin/busybox /usr/sbin/crond
            install -D -d -m 0755 -o root -g root /var/spool/cron/crontabs
        ;;

        "alpine")
            apk add --no-cache busybox-suid
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
        install -D -m 0755 -o root -g root service-run /etc/sv/cron/run
        install -d -m 0755 -o root -g root /etc/service
        ln -sf /etc/sv/cron /etc/service/cron
    fi

    if [ -d /var/lib/entrypoint.d ]; then
        install -m 0755 -o root -g root entrypoint.sh /var/lib/entrypoint.d/50-cron
    fi

    if [ "${RUN_WP_CRON:-}" = 'true' ] && [ -n "${WP_CRON_SCHEDULE:-}" ]; then
        install -m 0755 -o root -g root wp-cron.sh /usr/local/bin/wp-cron.sh
        echo "${WP_CRON_SCHEDULE} /usr/bin/flock -n /tmp/wp-cron.lock /usr/local/bin/wp-cron.sh" | crontab -u "${_REMOTE_USER}" -
    fi

    echo 'Done!'
fi
