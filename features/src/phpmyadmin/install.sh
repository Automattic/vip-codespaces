#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
NGINX_USER=

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing phpMyAdmin...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/phpmyadmin
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/phpmyadmin/

    # shellcheck source=/dev/null
    . /etc/os-release
    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            PACKAGES=""
            if ! hash htpasswd >/dev/null 2>&1 && test -d /etc/nginx/conf.extra; then
                PACKAGES="${PACKAGES} apache2-utils"
            fi

            if ! hash curl >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} curl"
            fi

            if ! hash update-ca-certificates >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} ca-certificates"
            fi

            if [ -n "${PACKAGES}" ]; then
                apt-get update
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
            fi

            apt-get clean
            rm -rf /var/lib/apt/lists/*
            NGINX_USER=www-data
        ;;

        "alpine")
            PACKAGES=""
            if ! hash htpasswd >/dev/null 2>&1 && test -d /etc/nginx/conf.extra; then
                PACKAGES="${PACKAGES} apache2-utils"
            fi

            if ! hash curl >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} curl"
            fi

            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}
            NGINX_USER=nginx
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    install -D -d -m 0755 -o root -g root /usr/share/webapps/phpmyadmin /etc/phpmyadmin /etc/conf.d
    curl -SL https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz | tar --strip-components=1 -zxm -f - -C /usr/share/webapps/phpmyadmin

    LC_ALL=C < /dev/urandom tr -dc _A-Z-a-z-0-9 2> /dev/null | head -c24 > /etc/conf.d/phpmyadmin-password
    if [ -d /etc/nginx/conf.extra ]; then
        htpasswd -nim vipgo < /etc/conf.d/phpmyadmin-password > /etc/nginx/conf.extra/.htpasswd-pma
        chown "${NGINX_USER}:${NGINX_USER}" /etc/nginx/conf.extra/.htpasswd-pma
        chmod 0600 /etc/nginx/conf.extra/.htpasswd-pma
    fi

    homedir="$(getent passwd "${_REMOTE_USER}" | cut -d: -f6)"
    if [ -d "${homedir}/.local/share/vip-codespaces/login" ]; then
        {
            echo "echo \"*** phpMyAdmin Credentials ***\""
            echo "echo \"phpMyAdmin username: vipgo\""
            echo "echo \"phpMyAdmin password: $(cat /etc/conf.d/phpmyadmin-password || true)\""
            echo "echo"
        } >> "${homedir}/.local/share/vip-codespaces/login/050-phpmyadmin.sh"
    fi

    install -d -m 0777 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" /usr/share/webapps/phpmyadmin/tmp
    install -m 0640 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" config.inc.php /etc/phpmyadmin/config.inc.php
    ln -sf /etc/phpmyadmin/config.inc.php /usr/share/webapps/phpmyadmin/config.inc.php

    if [ -d /etc/nginx/sites-available ]; then
        install -m 0640 nginx-phpmyadmin.conf /etc/nginx/sites-available/phpmyadmin.conf
        ln -sf /etc/nginx/sites-available/phpmyadmin.conf /etc/nginx/sites-enabled/phpmyadmin.conf
    fi

    echo 'Done!'
fi
