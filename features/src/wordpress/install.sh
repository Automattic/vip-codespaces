#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Downloading WordPress...'

if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    WEB_USER="${CONTAINER_USER:-www-data}"
else
    WEB_USER="${_REMOTE_USER}"
fi

: "${MOVEUPLOADSTOWORKSPACES:=}"
: "${MULTISITE:=}"
: "${VERSION:=latest}"

install -d -m 0755 -o root -g root /etc/wp-cli /usr/share/wordpress
install -m 0644 -o root -g root wp-cli.yaml /etc/wp-cli
install -d -o "${WEB_USER}" -g "${WEB_USER}" -m 0755 /wp
cp -a wp/* /wp && chown -R "${WEB_USER}:${WEB_USER}" /wp/* && chmod -R 0755 /wp/* && find /wp -type f -exec chmod 0644 {} \;
su-exec "${WEB_USER}:${WEB_USER}" wp core download --path=/wp --skip-content --version="${VERSION}"

if [ "${MOVEUPLOADSTOWORKSPACES}" != 'true' ]; then
    WP_PERSIST_UPLOADS=""
else
    WP_PERSIST_UPLOADS=1
fi

install -m 0755 -o root -g root setup-wordpress.sh /usr/local/bin/setup-wordpress.sh
install -m 0644 -o root -g root wp-config.php.tpl /usr/share/wordpress/
install -m 0644 -o root -g root 010-wplogin.tpl /usr/share/wordpress/
install -d -D -m 0755 -o root -g root /var/lib/wordpress/postinstall.d

WP_DOMAIN="${DOMAIN:-localhost}"
if [ "${MULTISITE}" != 'true' ]; then
    WP_MULTISITE=""
else
    WP_MULTISITE=1
fi
WP_MULTISITE_TYPE="${MULTISITE_TYPE:-subdirectory}"

export WP_DOMAIN WP_MULTISITE WP_MULTISITE_TYPE WP_PERSIST_UPLOADS
# shellcheck disable=SC2016
envsubst '$WP_DOMAIN $WP_MULTISITE $WP_MULTISITE_TYPE $WP_PERSIST_UPLOADS' < conf-wordpress.tpl > /etc/conf.d/wordpress

echo 'Done!'
