#!/bin/sh

set -e
exec 2>&1

umask 0002

# shellcheck disable=SC2312
ES_JAVA_HOME="$(dirname "$(dirname "$(readlink -f /usr/bin/java)")")"
ES_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ ${ES_JAVA_OPTS:-}"
export ES_JAVA_HOME ES_JAVA_OPTS

# shellcheck disable=SC2154 # ES_USER and ES_DATADIR are substituted by `install.sh`.
chown -R "${ES_USER}:${ES_USER}" "${ES_DATADIR}/data" /opt/elasticsearch/logs
# shellcheck disable=SC2154
exec su-exec "${ES_USER}" /usr/bin/elasticsearch
