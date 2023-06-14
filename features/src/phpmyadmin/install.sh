#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${ENABLED:=}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing phpMyAdmin...'

    if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
        WEB_USER="${CONTAINER_USER:-www-data}"
    else
        WEB_USER="${_REMOTE_USER}"
    fi

    apk add --no-cache apache2-utils
    install -D -d -m 0755 -o root -g root /usr/share/webapps/phpmyadmin /etc/phpmyadmin
    wget -q https://files.phpmyadmin.net/phpMyAdmin/5.2.1/phpMyAdmin-5.2.1-all-languages.tar.gz -O - | tar --strip-components=1 -zxm -f - -C /usr/share/webapps/phpmyadmin

    LC_ALL=C < /dev/urandom tr -dc _A-Z-a-z-0-9 2> /dev/null | head -c24 | sudo tee -i /etc/conf.d/phpmyadmin-password
    htpasswd -nim vipgo < /etc/conf.d/phpmyadmin-password > /etc/nginx/conf.extra/.htpasswd-pma
    sudo chown "${WEB_USER}:${WEB_USER}" /etc/conf.d/phpmyadmin-password /etc/nginx/conf.extra/.htpasswd-pma
    chmod 0600 /etc/conf.d/phpmyadmin-password /etc/nginx/conf.extra/.htpasswd-pma

    homedir=$(getent passwd "${WEB_USER}" | cut -d: -f6)
    {
        echo "echo \"*** phpMyAdmin Credentials\" ***"
        echo "echo \"phpMyAdmin username: vipgo\""
        echo "echo \"phpMyAdmin password: $(cat /etc/conf.d/phpmyadmin-password || true)\""
        echo "echo"
    } >> "${homedir}/.local/share/vip-codespaces/login/050-phpmyadmin.sh"

    install -m 0640 nginx-phpmyadmin.conf /etc/nginx/http.d/phpmyadmin.conf
    install -d -m 0777 -o "${WEB_USER}" -g "${WEB_USER}" /usr/share/webapps/phpmyadmin/tmp
    install -m 0640 -o "${WEB_USER}" -g "${WEB_USER}" config.inc.php /etc/phpmyadmin/config.inc.php
    ln -sf /etc/phpmyadmin/config.inc.php /usr/share/webapps/phpmyadmin/config.inc.php
    echo 'Done!'
fi
