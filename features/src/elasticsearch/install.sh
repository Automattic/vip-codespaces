#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
: "${INSTALLDATATOWORKSPACES:?}"
: "${INSTALL_RUNIT_SERVICE:=true}"

ES_VERSION="${VERSION:-7.17.28}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing Elasticsearch...'

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    if [ "${_REMOTE_USER}" = "root" ]; then
        ES_USER=elasticsearch
    else
        ES_USER="${_REMOTE_USER}"
    fi

    PACKAGES=""
    ENTRYPOINT=""
    if ! hash curl >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} curl"
    fi

    if ! hash update-ca-certificates >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} ca-certificates"
    fi

    if ! hash zip >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} zip"
    fi

    if ! hash unzip >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} unzip"
    fi

    if ! hash envsubst >/dev/null 2>&1; then
        PACKAGES="${PACKAGES} gettext"
    fi

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            if ! hash trust >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} p11-kit"
            fi

            # Elastcsearch's Dockerfile says ES need netcat
            # https://github.com/elastic/dockerfiles/blob/15cf539642c8466777c84a3dd969e9678f31605c/elasticsearch/Dockerfile#L90
            if ! hash nc >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} netcat-openbsd"
            fi

            if [ "${_REMOTE_USER}" = "root" ] && ! hash adduser >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} adduser"
            fi

            if [ -n "${PACKAGES}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
                apt-get clean
                rm -rf /var/lib/apt/lists/*
            fi

            if [ "${_REMOTE_USER}" = "root" ]; then
                adduser --disabled-login --home /usr/share/elasticsearch --no-create-home --gecos '' "${ES_USER}"
            fi

            ENTRYPOINT=entrypoint-deb.tpl
        ;;

        "alpine")
            PACKAGES="${PACKAGES} openjdk17-jre-headless"
            if ! hash trust >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} p11-kit-trust"
            fi

            if ! hash bash >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} bash"
            fi

            if [ ! -x /sbin/chpst ] && [ ! -x /sbin/su-exec ]; then
                PACKAGES="${PACKAGES} su-exec"
            fi

            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}

            if [ "${_REMOTE_USER}" = "root" ]; then
                adduser -h /usr/share/elasticsearch -s /sbin/nologin -H -D "${ES_USER}"
            fi

            ENTRYPOINT=entrypoint-alpine.tpl
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    ARCH="$(arch)"
    install -d -m 0755 -o "${ES_USER}" -g "${ES_USER}" /usr/share/elasticsearch
    if [ -f "elasticsearch-${ES_VERSION}-linux-${ARCH}.tar.gz" ]; then
        cp "elasticsearch-${ES_VERSION}-linux-${ARCH}.tar.gz" /tmp/elasticsearch.tar.gz
    else
        curl -SLf -o /tmp/elasticsearch.tar.gz "https://artifacts-no-kpi.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}-linux-${ARCH}.tar.gz"
    fi

    tar -C /usr/share/elasticsearch -zxf /tmp/elasticsearch.tar.gz --strip-components=1
    rm -f /tmp/elasticsearch.tar.gz
    if [ "${ID_LIKE}" = "alpine" ]; then
        rm -rf "/usr/share/elasticsearch/modules/x-pack-ml/platform/linux-${ARCH}"
    fi

    if [ "${INSTALLDATATOWORKSPACES}" != 'true' ]; then
        ES_DATADIR=/usr/share/elasticsearch/data
    else
        ES_DATADIR=/workspaces/es-data
    fi

    install -D -d -m 0755 -o "${ES_USER}" -g "${ES_USER}" "${ES_DATADIR}"
    for path in config logs tmp plugins; do \
        install -D -d -o "${ES_USER}" -g "${ES_USER}" "/usr/share/elasticsearch/${path}"
        chown -R "${ES_USER}:${ES_USER}" "/usr/share/elasticsearch/${path}"
    done

    chmod -R a+rX /usr/share/elasticsearch
    for file in /usr/share/elasticsearch/bin/*; do
        ln -s "${file}" "/usr/bin/$(basename "${file}")"
    done

    export ES_DATADIR ES_USER
    # shellcheck disable=SC2016
    envsubst '$ES_DATADIR' < elasticsearch.yml.tpl > /usr/share/elasticsearch/config/elasticsearch.yml
    chown "${ES_USER}:${ES_USER}" /usr/share/elasticsearch/config/elasticsearch.yml
    chmod 0644 /usr/share/elasticsearch/config/elasticsearch.yml

    if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
        install -D -d -m 0755 -o root -g root /etc/service /etc/sv/elasticsearch
        # shellcheck disable=SC2016
        envsubst '$ES_DATADIR $ES_USER' < service-run.tpl > /etc/sv/elasticsearch/run && chmod 0755 /etc/sv/elasticsearch/run
        ln -sf /etc/sv/elasticsearch /etc/service/elasticsearch
    fi

    if [ -d /var/lib/entrypoint.d ]; then
        # shellcheck disable=SC2016
        envsubst '$ES_DATADIR $ES_USER' < "${ENTRYPOINT}" > /var/lib/entrypoint.d/50-elasticsearch
        chmod 0755 /var/lib/entrypoint.d/50-elasticsearch
    fi

    if [ -d /var/lib/wordpress/postinstall.d ]; then
        install -m 0755 -o root -g root post-wp-install.sh /var/lib/wordpress/postinstall.d/50-elasticsearch.sh
    fi

    install -m 0755 -o root -g root es-update-certs /etc/ca-certificates/update.d/es-update-certs
    /etc/ca-certificates/update.d/es-update-certs

    echo 'Done!'
fi
