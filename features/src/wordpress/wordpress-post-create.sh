#!/bin/sh

if [ ! -f "${HOME}/.local/share/vip-codespaces/login/010-wplogin.sh" ]; then
    exec /usr/local/bin/setup-wordpress.sh
fi
