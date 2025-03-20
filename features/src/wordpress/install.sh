#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${MOVEUPLOADSTOWORKSPACES:=}"
: "${MULTISITE:=}"
: "${VERSION:=latest}"

if [ "${MOVEUPLOADSTOWORKSPACES}" != 'true' ]; then
    WP_PERSIST_UPLOADS=""
else
    WP_PERSIST_UPLOADS=1
fi

WP_DOMAIN="${DOMAIN:-localhost}"
if [ "${MULTISITE}" != 'true' ]; then
    WP_MULTISITE=""
else
    WP_MULTISITE=1
fi
WP_MULTISITE_TYPE="${MULTISITE_TYPE:-subdirectory}"

echo '(*) Downloading WordPress...'

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/wordpress
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/wordpress/

install -d -m 0755 -o root -g root /etc/wp-cli /usr/share/wordpress
install -m 0644 -o root -g root wp-cli.yaml /etc/wp-cli
install -d -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" -m 0755 /wp
cp -a wp/* /wp
chmod -R 0755 /wp
find /wp -type f -exec chmod 0644 {} \;
wp --allow-root core download --path=/wp --skip-content --version="${VERSION}"
chown -R "${_REMOTE_USER}:${_REMOTE_USER}" /wp

install -m 0755 -o root -g root setup-wordpress.sh wordpress-post-create.sh wordpress-update-content.sh /usr/local/bin/
install -m 0644 -o root -g root wp-config.php.tpl 010-wplogin.tpl /usr/share/wordpress/
install -d -D -m 0755 -o root -g root /var/lib/wordpress/postinstall.d /etc/conf.d

export WP_DOMAIN WP_MULTISITE WP_MULTISITE_TYPE WP_PERSIST_UPLOADS
# shellcheck disable=SC2016
envsubst '$WP_DOMAIN $WP_MULTISITE $WP_MULTISITE_TYPE $WP_PERSIST_UPLOADS' < conf-wordpress.tpl > /etc/conf.d/wordpress

echo 'Done!'
