#!/bin/sh

if [ -f composer.json ] && [ -x /usr/local/bin/composer ]; then
    /usr/local/bin/composer install -n || true
fi

if [ ! -f "${HOME}/.local/share/vip-codespaces/login/010-wplogin.sh" ]; then
    /usr/local/bin/setup-wordpress.sh
fi
