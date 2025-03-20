#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
: "${MEMORY_SIZE:=64}"
: "${INSTALL_RUNIT_SERVICE:=true}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing memcached...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/memcached
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/memcached/

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"
    RUN_AS=""

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            PACKAGES="memcached"
            if ! hash envsubst >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} gettext"
            fi

            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}
            apt-get clean
            rm -rf /var/lib/apt/lists/*
            update-rc.d -f memcached remove
            RUN_AS="memcache"
        ;;

        "alpine")
            PACKAGES="memcached"
            if ! hash envsubst >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} gettext"
            fi

            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}
            RUN_AS="memcached"
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    if [ -d /wp/wp-content ]; then
        install -m 0644 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" object-cache.php /wp/wp-content/
    fi

    export RUN_AS
    export MEMORY_SIZE

    if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
        install -D -d -m 0755 -o root -g root /etc/service /etc/sv/memcached
        # shellcheck disable=SC2016
        envsubst '$RUN_AS $MEMORY_SIZE' < service-run.tpl > /etc/sv/memcached/run && chmod 0755 /etc/sv/memcached/run
        ln -sf /etc/sv/memcached /etc/service/memcached
    fi

    if [ -d /var/lib/entrypoint.d ]; then
        # shellcheck disable=SC2016
        envsubst '$RUN_AS $MEMORY_SIZE' < entrypoint.tpl > /var/lib/entrypoint.d/50-memcached
        chmod 0755 /var/lib/entrypoint.d/50-memcached
    fi

    echo 'Done!'
fi
