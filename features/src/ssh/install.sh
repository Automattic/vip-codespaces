#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ "${ENABLED:-}" = "true" ]; then
    echo '(*) Installing OpenSSH server...'

    apk add --no-cache openssh-server
    rm -f /etc/conf.d/sshd /etc/init.d/sshd
    install -D -d -m 0555 -o root -g root /var/empty
    install -d -m 0755 -o root -g root /etc/service
    install -D -m 0755 -o root -g root service-run /etc/sv/openssh/run
    ln -sf /etc/sv/openssh /etc/service/openssh

    echo 'Done!'
fi
