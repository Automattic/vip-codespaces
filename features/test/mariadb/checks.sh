#!/bin/bash

second=0
while ! mariadb-admin ping -u root -h 127.0.0.1 --silent && [[ "${second}" -lt 60 ]]; do
    sleep 1
    second=$((second + 1))
done
check "MariaDB is online" mariadb-admin ping -u root -h 127.0.0.1 --silent

if hash sv > /dev/null 2>&1; then
    check "mariadb is running" sudo sh -c 'sv status mariadb | grep -E ^run:'
    sudo sv stop mariadb
    check "mariadb is stopped" sudo sh -c 'sv status mariadb | grep -E ^down:'
    sudo sv start mariadb
else
    check "mariadb is running" pgrep mariadbd
fi

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
