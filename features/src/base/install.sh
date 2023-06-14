#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    THE_USER="${CONTAINER_USER:-www-data}"
else
    THE_USER="${_REMOTE_USER}"
fi

{
    echo "@edgem https://dl-cdn.alpinelinux.org/alpine/edge/main"
    echo "@edgec https://dl-cdn.alpinelinux.org/alpine/edge/community"
    echo "@edget https://dl-cdn.alpinelinux.org/alpine/edge/testing"
} >> /etc/apk/repositories


HOME_DIR="$(getent passwd "${THE_USER}" | cut -d: -f6)"

install -d -D -m 0755 -o "${THE_USER}" -g "${THE_USER}" "${HOME_DIR}/.local/share/vip-codespaces"
install -d -D -m 0755 -o "${THE_USER}" -g "${THE_USER}" "${HOME_DIR}/.local/share/vip-codespaces/login"

install -m 0644 -o "${THE_USER}" -g "${THE_USER}" .bashrc "${HOME_DIR}/.bashrc"
install -m 0644 -o "${THE_USER}" -g "${THE_USER}" 001-welcome.sh "${HOME_DIR}/.local/share/vip-codespaces/login/001-welcome.sh"
