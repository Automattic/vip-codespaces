#!/bin/bash

if hash sv > /dev/null 2>&1; then
    check "tigervnc is running" sudo sh -c 'sv status tigervnc | grep -E ^run:'
    sudo sv stop tigervnc
    check "tigervnc is stopped" sudo sh -c 'sv status tigervnc | grep -E ^down:'
    sudo sv start tigervnc
    # shellcheck disable=SC2034
    for i in {1..10}; do
        # shellcheck disable=SC2312
        sudo sv status tigervnc | grep -Eq '^run:' && break
        sleep 1
    done
    check "tigervnc is running" sudo sh -c 'sv status tigervnc | grep -E ^run:'

    check "openbox is running" sudo sh -c 'sv status openbox | grep -E ^run:'
    sudo sv stop openbox
    check "openbox is stopped" sudo sh -c 'sv status openbox | grep -E ^down:'
    sudo sv start openbox
    # shellcheck disable=SC2034
    for i in {1..10}; do
        # shellcheck disable=SC2312
        sudo sv status openbox | grep -Eq '^run:' && break
        sleep 1
    done
    check "openbox is running" sudo sh -c 'sv status openbox | grep -E ^run:'

    check "novnc is running" sudo sh -c 'sv status novnc | grep -E ^run:'
    sudo sv stop novnc
    check "novnc is stopped" sudo sh -c 'sv status novnc | grep -E ^down:'
    sudo sv start novnc
    # shellcheck disable=SC2034
    for i in {1..10}; do
        # shellcheck disable=SC2312
        sudo sv status novnc | grep -Eq '^run:' && break
        sleep 1
    done
    check "novnc is running" sudo sh -c 'sv status novnc | grep -E ^run:'
else
    check "tigervnc is running" pgrep Xtigervnc
    check "openbox is running" pgrep openbox
    check "novnc is running" pgrep easy-novnc
fi

if hash netstat > /dev/null 2>&1; then
    check "Port 5800 is open" sh -c 'netstat -lnt | grep :5800'
    check "Port 5900 is open" sh -c 'netstat -lnt | grep :5900'
    check "Port 6000 is open" sh -c 'netstat -lnt | grep :6000'
fi

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi
