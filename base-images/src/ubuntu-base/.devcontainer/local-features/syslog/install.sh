#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends busybox-static busybox-syslogd
apt-get clean
rm -rf /var/lib/apt/lists/*

update-rc.d -f busybox-klogd remove
update-rc.d -f busybox-syslogd remove

install -D -m 0755 -o root -g root service-run /etc/sv/syslog/run
install -d -m 0755 -o root -g root /etc/service
ln -sf /etc/sv/syslog /etc/service/syslog
