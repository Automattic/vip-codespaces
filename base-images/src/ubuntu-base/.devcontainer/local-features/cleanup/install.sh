#!/bin/sh

set -e

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

update-rc.d -f dbus remove
update-rc.d -f rsync remove
