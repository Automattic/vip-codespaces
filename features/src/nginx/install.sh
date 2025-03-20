#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

echo '(*) Installing nginx...'

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/nginx
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/nginx/

MEDIA_REDIRECT_URL="${MEDIAREDIRECTURL:-}"
: "${INSTALL_RUNIT_SERVICE:=true}"

# shellcheck source=/dev/null
. /etc/os-release
: "${ID:=}"
: "${ID_LIKE:=${ID}}"
NGINX_USER=

case "${ID_LIKE}" in
    "debian")
        export DEBIAN_FRONTEND=noninteractive
        PACKAGES="nginx"
        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        # /etc/nginx, /etc/nginx/conf.d, /etc/nginx/modules-available, /etc/nginx/modules-enabled, /etc/nginx/sites-available, /etc/nginx/sites-enabled, /etc/nginx/snippets
        # nginx.conf:
        #   top-level: include /etc/nginx/modules-enabled/*.conf;
        #   http: include /etc/nginx/conf.d/*.conf; include /etc/nginx/sites-enabled/*;
        apt-get update
        # shellcheck disable=SC2086
        apt-get install -y --no-install-recommends ${PACKAGES}
        apt-get clean
        rm -rf /var/lib/apt/lists/*
        update-rc.d -f nginx remove
        rm -f /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
        sed -i '/pid \/run\/nginx.pid;/d' /etc/nginx/nginx.conf
        NGINX_USER=www-data
    ;;

    "alpine")
        PACKAGES="nginx"
        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        # /etc/nginx, /etc/nginx/http.d, /etc/nginx/modules
        # nginx.conf:
        #   top-level: include /etc/nginx/modules/*.conf; include /etc/nginx/conf.d/*.conf;
        #   http: include /etc/nginx/http.d/*.conf;
        # shellcheck disable=SC2086
        apk add --no-cache ${PACKAGES}
        rm -f /etc/nginx/http.d/default.conf
        install -d -D -m 0755 -o root -g root /etc/nginx/sites-enabled /etc/nginx/sites-available
        sed -i '/include \/etc\/nginx\/http.d\/\*.conf;/a \\tinclude \/etc\/nginx\/sites-enabled\/*;' /etc/nginx/nginx.conf
        NGINX_USER=nginx
    ;;

    *)
        echo "Unsupported distribution: ${ID_LIKE}"
        exit 1
    ;;
esac

install -d -D -m 0755 -o root -g root /etc/nginx/conf.extra /etc/conf.d

export NGINX_USER MEDIA_REDIRECT_URL

if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
    install -D -d -m 0755 -o root -g root /etc/service /etc/sv/nginx
    # shellcheck disable=SC2016
    envsubst '$NGINX_USER' < service-run.tpl > /etc/sv/nginx/run && chmod 0755 /etc/sv/nginx/run
    ln -sf /etc/sv/nginx /etc/service/nginx
fi

if [ -d /var/lib/entrypoint.d ]; then
    # shellcheck disable=SC2016
    envsubst '$NGINX_USER' < entrypoint.tpl > /var/lib/entrypoint.d/50-nginx
    chmod 0755 /var/lib/entrypoint.d/50-nginx
fi

# shellcheck disable=SC2016
envsubst '$MEDIA_REDIRECT_URL' < conf-nginx.tpl > /etc/conf.d/nginx

if [ -n "${MEDIA_REDIRECT_URL}" ]; then
    # shellcheck disable=SC2016
    envsubst '$MEDIA_REDIRECT_URL' < media-redirect.tpl > /etc/nginx/conf.extra/media-redirect.conf
fi

install -m 0644 -o root -g root default.conf /etc/nginx/sites-available/default.conf
ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

nginx -t

echo 'Done!'
