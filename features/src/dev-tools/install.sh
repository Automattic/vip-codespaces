#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"

echo '(*) Installing Dev Tools...'

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/dev-tools
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/dev-tools/

install -d -D -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /wp/wp-content/mu-plugins
install -m 0644 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" dev-env-plugin.php /wp/wp-content/mu-plugins/dev-env-plugin.php

install -d -m 0755 -o root -g root /etc/vip-go-mu-plugins
if [ -f /etc/vip-go-mu-plugins/.rsyncignore ]; then
    touch /etc/vip-go-mu-plugins/.rsyncignore
fi

if ! grep -qF dev-env-plugin.php /etc/vip-go-mu-plugins/.rsyncignore; then
    echo 'dev-env-plugin.php' >> /etc/vip-go-mu-plugins/.rsyncignore
fi

echo 'Done!'
