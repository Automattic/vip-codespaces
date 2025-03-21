#!/bin/sh

PATH=/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

install -m 0755 -o root -g root internal-introspection-ep.sh internal-introspection-on-create.sh internal-introspection-post-create.sh internal-introspection-post-start.sh internal-introspection-post-attach.sh internal-introspection-update-content.sh /usr/local/bin/

install -d -D -m 0777 /usr/local/etc/vscode-dev-containers/vip-codespaces/internal-introspection
env | sort > /usr/local/etc/vscode-dev-containers/vip-codespaces/internal-introspection/build.env
pwd > /usr/local/etc/vscode-dev-containers/vip-codespaces/internal-introspection/build.pwd
