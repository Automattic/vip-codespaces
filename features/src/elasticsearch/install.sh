#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin
ES_VERSION="7.17.2"
ES_TARBALL="https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-${ES_VERSION}-no-jdk-linux-x86_64.tar.gz"

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:?}"
: "${INSTALLDATATOWORKSPACES:?}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing Elasticsearch...'

    if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
        ES_USER=elasticsearch
        adduser -M -r -d /usr/share/elasticsearch -s /sbin/nologin "${ES_USER}"
    else
        ES_USER="${_REMOTE_USER}"
    fi

    apk add --no-cache openjdk11-jre-headless

    if [ "${INSTALLDATATOWORKSPACES}" != 'true' ]; then
        ES_DATADIR=/opt/elasticsearch
    else
        ES_DATADIR=/workspaces/es-data
        install -D -d -m 0755 -o "${ES_USER}" -g "${ES_USER}" "${ES_DATADIR}"
    fi

    (
        set -e
        cd /tmp
        wget -q -O elasticsearch.tar.gz "${ES_TARBALL}"
        tar -xf elasticsearch.tar.gz
        mv "elasticsearch-${ES_VERSION}" /opt/elasticsearch
        rm -rf /tmp/elasticsearch.tar.gz /opt/elasticsearch/modules/x-pack-ml/platform/linux-x86_64
    )

    install -D -d -o "${ES_USER}" -g "${ES_USER}" "${ES_DATADIR}/data"
    for path in config logs tmp plugins; do \
        install -D -d -o "${ES_USER}" -g "${ES_USER}" "/opt/elasticsearch/${path}"
        chown -R "${ES_USER}:${ES_USER}" "/opt/elasticsearch/${path}"
    done

    for file in /opt/elasticsearch/bin/*; do
        ln -s "${file}" "/usr/bin/$(basename "${file}")"
    done

    export ES_DATADIR
    # shellcheck disable=SC2016
    envsubst '$ES_DATADIR' < elasticsearch.yml.tpl > /opt/elasticsearch/config/elasticsearch.yml
    chown "${ES_USER}:${ES_USER}" /opt/elasticsearch/config/elasticsearch.yml

    install -D -d -m 0755 -o root -g root /etc/sv/elasticsearch

    export ES_USER
    # shellcheck disable=SC2016
    envsubst '$ES_DATADIR $ES_USER' < service-run.tpl > /etc/sv/elasticsearch/run
    chmod 0755 /etc/sv/elasticsearch/run

    install -d -m 0755 -o root -g root /etc/service
    ln -sf /etc/sv/elasticsearch /etc/service/elasticsearch

    install -D -m 0755 -o root -g root post-wp-install.sh /var/lib/wordpress/postinstall.d/50-elasticsearch.sh

    echo 'Done!'
fi
