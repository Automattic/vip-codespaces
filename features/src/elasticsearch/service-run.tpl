#!/bin/sh

set -e
exec 2>&1

umask 0002

ES_JAVA_HOME=$(dirname "$(dirname "$(readlink -f /usr/bin/java)")")
ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ ${ES_JAVA_OPTS:-}"
export ES_JAVA_HOME ES_JAVA_OPTS

chown -R "${ES_USER}:${ES_USER}" "${ES_DATADIR}/data" /opt/elasticsearch/logs
exec su-exec "${ES_USER}" /usr/bin/elasticsearch
