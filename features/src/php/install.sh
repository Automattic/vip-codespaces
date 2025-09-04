#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${VERSION:?}"
: "${COMPOSER:=}"
PHP_VERSION="${VERSION}"
: "${INSTALL_RUNIT_SERVICE:=true}"
: "${LITE_INSTALL:=}"
: "${SKIP_GMAGICK:=}"

setup_php81_alpine() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="icu-data-full ghostscript php81-bcmath php81-pecl-mcrypt php81-soap php81-pecl-igbinary php81-pecl-ssh2 php81-pecl-timezonedb"
    else
        EXTENSIONS=
    fi

    # shellcheck disable=SC2086 # We need to expand $REPOS
    apk add --no-cache \
        php81 php81-fpm php81-pear \
        php81-pecl-apcu \
        php81-calendar \
        php81-ctype \
        php81-curl \
        php81-dom \
        php81-exif \
        php81-fileinfo \
        php81-ftp \
        php81-gd \
        php81-gmp \
        php81-iconv \
        php81-json \
        php81-mbstring \
        php81-pecl-memcache \
        php81-pecl-memcached \
        php81-mysqli \
        php81-mysqlnd \
        php81-opcache \
        php81-openssl \
        php81-pcntl \
        php81-pdo \
        php81-pdo_mysql \
        php81-pdo_sqlite \
        php81-phar \
        php81-posix \
        php81-session \
        php81-shmop \
        php81-simplexml \
        php81-sockets \
        php81-sodium \
        php81-sqlite3 \
        php81-sysvsem \
        php81-sysvshm \
        php81-tokenizer \
        php81-xml \
        php81-xmlreader \
        php81-xmlwriter \
        php81-zip ${EXTENSIONS} -X https://dl-cdn.alpinelinux.org/alpine/v3.19/main -X https://dl-cdn.alpinelinux.org/alpine/v3.19/community

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        apk add --no-cache php81-dev gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp -X https://dl-cdn.alpinelinux.org/alpine/v3.19/main -X https://dl-cdn.alpinelinux.org/alpine/v3.19/community
        pecl81 channel-update pecl.php.net
        pecl81 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
        apk del --no-cache php81-dev gcc make libc-dev graphicsmagick-dev libtool
        echo "extension=gmagick.so" > /etc/php81/conf.d/40_gmagick.ini
    fi

    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear81 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev81 /usr/bin/peardev
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl81 /usr/bin/pecl
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar.phar81 /usr/bin/phar.phar
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar81 /usr/bin/phar
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php81 /usr/bin/php
    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm
    true
}

setup_php82_alpine() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="icu-data-full ghostscript php82-bcmath php82-intl php82-pecl-mcrypt php82-soap php82-pecl-igbinary php82-pecl-ssh2 php82-pecl-timezonedb"
    else
        EXTENSIONS=
    fi

    # shellcheck disable=SC2086
    apk add --no-cache \
        php82 php82-fpm php82-pear \
        php82-pecl-apcu \
        php82-calendar \
        php82-ctype \
        php82-curl \
        php82-dom \
        php82-exif \
        php82-fileinfo \
        php82-ftp \
        php82-gd \
        php82-gmp \
        php82-iconv \
        php82-mbstring \
        php82-pecl-memcache \
        php82-pecl-memcached \
        php82-mysqli \
        php82-mysqlnd \
        php82-opcache \
        php82-openssl \
        php82-pcntl \
        php82-pdo \
        php82-pdo_mysql \
        php82-pdo_sqlite \
        php82-phar \
        php82-posix \
        php82-session \
        php82-shmop \
        php82-simplexml \
        php82-sockets \
        php82-sodium \
        php82-sqlite3 \
        php82-sysvsem \
        php82-sysvshm \
        php82-tokenizer \
        php82-xml \
        php82-xmlreader \
        php82-xmlwriter \
        php82-zip ${EXTENSIONS}

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        apk add --no-cache php82-dev gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp
        pecl82 channel-update pecl.php.net
        pecl82 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
        apk del --no-cache php82-dev gcc make libc-dev graphicsmagick-dev libtool
        echo "extension=gmagick.so" > /etc/php82/conf.d/40_gmagick.ini
    fi

    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear82 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev82 /usr/bin/peardev
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl82 /usr/bin/pecl
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar.phar82 /usr/bin/phar.phar
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar82 /usr/bin/phar
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php82 /usr/bin/php
    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm82 /usr/sbin/php-fpm
    true
}

setup_php83_alpine() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="icu-data-full ghostscript php83-bcmath php83-ftp php83-intl php83-pecl-mcrypt php83-soap php83-pecl-igbinary php83-pecl-ssh2 php83-pecl-timezonedb"
    else
        EXTENSIONS=
    fi

    # shellcheck disable=SC2086
    apk add --no-cache \
        icu-data-full ghostscript \
        php83 php83-fpm php83-pear \
        php83-pecl-apcu \
        php83-calendar \
        php83-ctype \
        php83-curl \
        php83-dom \
        php83-exif \
        php83-fileinfo \
        php83-ftp \
        php83-gd \
        php83-gmp \
        php83-iconv \
        php83-mbstring \
        php83-pecl-memcache \
        php83-pecl-memcached \
        php83-mysqli \
        php83-mysqlnd \
        php83-opcache \
        php83-openssl \
        php83-pcntl \
        php83-pdo \
        php83-pdo_mysql \
        php83-pdo_sqlite \
        php83-phar \
        php83-posix \
        php83-session \
        php83-shmop \
        php83-simplexml \
        php83-sockets \
        php83-sodium \
        php83-sqlite3 \
        php83-sysvsem \
        php83-sysvshm \
        php83-tokenizer \
        php83-xml \
        php83-xmlreader \
        php83-xmlwriter \
        php83-zip ${EXTENSIONS}

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        apk add --no-cache php83-dev gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp
        pecl83 channel-update pecl.php.net
        pecl83 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
        echo "extension=gmagick.so" > /etc/php83/conf.d/40_gmagick.ini
        apk del --no-cache php83-dev gcc make libc-dev graphicsmagick-dev libtool
    fi

    # Alpine 3.20: these symlinks are broken
    rm -f /usr/bin/phar /usr/bin/phar.phar

    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear83 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev83 /usr/bin/peardev
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl83 /usr/bin/pecl
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar.phar83 /usr/bin/phar.phar
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar83 /usr/bin/phar
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php83 /usr/bin/php
    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm83 /usr/sbin/php-fpm
    true
}

setup_php84_alpine() {
    alpine_version="$(cat /etc/alpine-release)"
    if [ "$(printf '%s\n' "3.21" "${alpine_version}" | sort -V | head -n1 || true)" = "3.21" ]; then
        REPOS=""
    else
        REPOS="-X https://dl-cdn.alpinelinux.org/alpine/v3.21/community"
    fi

    if [ "${LITE_INSTALL}" != 'true' ]; then
        # missing: php84-pecl-mcrypt php84-pecl-timezonedb
        EXTENSIONS="icu-data-full ghostscript php84-bcmath php84-ftp php84-intl php84-soap php84-pecl-igbinary php84-pecl-ssh2"
    else
        EXTENSIONS=
    fi

    # shellcheck disable=SC2086
    apk add --no-cache \
        icu-data-full ghostscript \
        php84 php84-fpm php84-pear \
        php84-pecl-apcu \
        php84-calendar \
        php84-ctype \
        php84-curl \
        php84-dom \
        php84-exif \
        php84-fileinfo \
        php84-ftp \
        php84-gd \
        php84-gmp \
        php84-iconv \
        php84-mbstring \
        php84-pecl-memcache \
        php84-pecl-memcached \
        php84-mysqli \
        php84-mysqlnd \
        php84-opcache \
        php84-openssl \
        php84-pcntl \
        php84-pdo \
        php84-pdo_mysql \
        php84-pdo_sqlite \
        php84-phar \
        php84-posix \
        php84-session \
        php84-shmop \
        php84-simplexml \
        php84-sockets \
        php84-sodium \
        php84-sqlite3 \
        php84-sysvsem \
        php84-sysvshm \
        php84-tokenizer \
        php84-xml \
        php84-xmlreader \
        php84-xmlwriter \
        php84-zip ${EXTENSIONS} ${REPOS}

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        # shellcheck disable=SC2086
        apk add --no-cache php84-dev gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp ${REPOS}
        pecl84 channel-update pecl.php.net
        pecl84 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
        echo "extension=gmagick.so" > /etc/php84/conf.d/40_gmagick.ini
        apk del --no-cache php84-dev gcc make libc-dev graphicsmagick-dev libtool
    fi

    # Alpine Edge: this symlink is broken
    rm -f /usr/bin/phar.phar

    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear84 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev84 /usr/bin/peardev
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl84 /usr/bin/pecl
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar.phar84 /usr/bin/phar.phar
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar84 /usr/bin/phar
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php84 /usr/bin/php
    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm84 /usr/sbin/php-fpm
    true
}

setup_php81_deb() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="ghostscript php8.1-bcmath php8.1-igbinary php8.1-intl php8.1-mcrypt php8.1-soap php8.1-ssh2"
    else
        EXTENSIONS=
    fi

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        EXTENSIONS="${EXTENSIONS} php8.1-gmagick"
    fi

    # shellcheck disable=SC2086
    eatmydata apt-get install -y --no-install-recommends \
        php8.1-cli php8.1-fpm \
        php8.1-apcu php8.1-curl php8.1-gd php8.1-gmp php8.1-mbstring \
        php8.1-memcache php8.1-memcached php8.1-mysql php8.1-sqlite3 php8.1-xml php8.1-zip ${EXTENSIONS}
    eatmydata apt-get install -y --no-install-recommends php-pear
    phpdismod ffi gettext readline sysvmsg xsl

    ln -s /usr/sbin/php-fpm8.1 /usr/sbin/php-fpm

    if [ "${LITE_INSTALL}" != 'true' ]; then
        PACKAGES="php8.1-dev"
        if ! hash make >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} make"
        fi

        # shellcheck disable=SC2086
        eatmydata apt-get install -y --no-install-recommends ${PACKAGES}
        pecl channel-update pecl.php.net
        pecl install timezonedb < /dev/null
        echo "extension=timezonedb.so" > /etc/php/8.1/mods-available/timezonedb.ini
        phpenmod timezonedb

        # shellcheck disable=SC2086
        eatmydata apt-get remove --purge -y ${PACKAGES}
    fi

    update-rc.d -f php8.1-fpm remove
}

setup_php82_deb() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="ghostscript php8.2-bcmath php8.2-igbinary php8.2-intl php8.2-mcrypt php8.2-soap php8.2-ssh2"
    else
        EXTENSIONS=
    fi

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        EXTENSIONS="${EXTENSIONS} php8.2-gmagick"
    fi

    # shellcheck disable=SC2086
    eatmydata apt-get install -y --no-install-recommends \
        php8.2-cli php8.2-fpm \
        php8.2-apcu php8.2-curl php8.2-gd php8.2-gmp php8.2-mbstring \
        php8.2-memcache php8.2-memcached php8.2-mysql php8.2-sqlite3 php8.2-xml php8.2-zip ${EXTENSIONS}
    eatmydata apt-get install -y --no-install-recommends php-pear
    phpdismod ffi gettext readline sysvmsg xsl

    ln -s /usr/sbin/php-fpm8.2 /usr/sbin/php-fpm

    if [ "${LITE_INSTALL}" != 'true' ]; then
        PACKAGES="php8.2-dev"
        if ! hash make >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} make"
        fi

        # shellcheck disable=SC2086
        eatmydata apt-get install -y --no-install-recommends ${PACKAGES}
        pecl channel-update pecl.php.net
        pecl install timezonedb < /dev/null
        echo "extension=timezonedb.so" > /etc/php/8.2/mods-available/timezonedb.ini
        phpenmod timezonedb

        # shellcheck disable=SC2086
        eatmydata apt-get remove --purge -y ${PACKAGES}
    fi

    update-rc.d -f php8.2-fpm remove
}

setup_php83_deb() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="ghostscript php8.3-bcmath php8.3-igbinary php8.3-intl php8.3-mcrypt php8.3-soap php8.3-ssh2"
    else
        EXTENSIONS=
    fi

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        EXTENSIONS="${EXTENSIONS} php8.3-gmagick"
    fi

    # shellcheck disable=SC2086
    eatmydata apt-get install -y --no-install-recommends \
        php8.3-cli php8.3-fpm \
        php8.3-apcu php8.3-curl php8.3-gd php8.3-gmp php8.3-mbstring \
        php8.3-memcache php8.3-memcached php8.3-mysql php8.3-sqlite3 php8.3-xml php8.3-zip ${EXTENSIONS}
    eatmydata apt-get install -y --no-install-recommends php-pear
    phpdismod ffi gettext readline sysvmsg xsl

    ln -s /usr/sbin/php-fpm8.3 /usr/sbin/php-fpm

    if [ "${LITE_INSTALL}" != 'true' ]; then
        PACKAGES="php8.3-dev"
        if ! hash make >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} make"
        fi

        # shellcheck disable=SC2086
        eatmydata apt-get install -y --no-install-recommends ${PACKAGES}
        pecl channel-update pecl.php.net
        pecl install timezonedb < /dev/null
        echo "extension=timezonedb.so" > /etc/php/8.3/mods-available/timezonedb.ini
        phpenmod timezonedb

        # shellcheck disable=SC2086
        eatmydata apt-get remove --purge -y ${PACKAGES}
    fi

    update-rc.d -f php8.3-fpm remove
}

setup_php84_deb() {
    if [ "${LITE_INSTALL}" != 'true' ]; then
        EXTENSIONS="ghostscript php8.4-bcmath php8.4-igbinary php8.4-intl php8.4-mcrypt php8.4-soap php8.4-ssh2"
    else
        EXTENSIONS=
    fi

    if [ "${SKIP_GMAGICK}" != 'true' ]; then
        EXTENSIONS="${EXTENSIONS} php8.4-gmagick"
    fi

    # shellcheck disable=SC2086
    eatmydata apt-get install -y --no-install-recommends \
        php8.4-cli php8.4-fpm \
        php8.4-apcu php8.4-curl php8.4-gd php8.4-gmp php8.4-mbstring \
        php8.4-memcache php8.4-memcached php8.4-mysql php8.4-sqlite3 php8.4-xml php8.4-zip ${EXTENSIONS}
    eatmydata apt-get install -y --no-install-recommends php-pear
    phpdismod ffi gettext readline sysvmsg xsl

    ln -s /usr/sbin/php-fpm8.4 /usr/sbin/php-fpm

    if [ "${LITE_INSTALL}" != 'true' ]; then
        PACKAGES="php8.4-dev"
        if ! hash make >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} make"
        fi

        # shellcheck disable=SC2086
        eatmydata apt-get install -y --no-install-recommends ${PACKAGES}
        pecl channel-update pecl.php.net
        pecl install timezonedb < /dev/null
        echo "extension=timezonedb.so" > /etc/php/8.4/mods-available/timezonedb.ini
        phpenmod timezonedb

        # shellcheck disable=SC2086
        eatmydata apt-get remove --purge -y ${PACKAGES}
    fi

    update-rc.d -f php8.4-fpm remove
}

echo "(*) Installing PHP ${PHP_VERSION}..."

install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/php
install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/php/

# shellcheck source=/dev/null
. /etc/os-release

: "${ID:=}"
: "${ID_LIKE:=${ID}}"

case "${ID_LIKE}" in
    "debian")
        export DEBIAN_FRONTEND=noninteractive
        PACKAGES=""
        if ! hash eatmydata >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} eatmydata"
        fi

        if ! hash curl >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} curl"
        fi

        if ! hash update-ca-certificates >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} ca-certificates"
        fi

        if ! hash gpg >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gnupg2"
        fi

        if ! hash lsb_release >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} lsb-release"
        fi

        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        if [ -n "${PACKAGES}" ]; then
            apt-get update
            # shellcheck disable=SC2086
            apt-get install -y --no-install-recommends ${PACKAGES}
        fi

        CODENAME="$(lsb_release -sc)"

        case "${ID}" in
            "debian")
                curl -SLo /tmp/debsuryorg-archive-keyring.deb https://packages.sury.org/debsuryorg-archive-keyring.deb
                dpkg -i /tmp/debsuryorg-archive-keyring.deb
                rm -f /tmp/debsuryorg-archive-keyring.deb
                echo "deb [signed-by=/usr/share/keyrings/debsuryorg-archive-keyring.gpg] https://packages.sury.org/php/ ${CODENAME} main" > /etc/apt/sources.list.d/php.list
            ;;

            "ubuntu")
                echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu ${CODENAME} main" > /etc/apt/sources.list.d/php.list
                curl -sSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x71DAEAAB4AD4CAB6" | gpg --dearmor > /etc/apt/trusted.gpg.d/ppa-ondrej-php.gpg
            ;;

            *)
                echo "(!) Unsupported distribution: ${ID}"
                exit 1
        esac

        apt-get update

        case "${PHP_VERSION}" in
            "8.0"|"8.1")
                PHP_VERSION="8.1"
                PHP_INI_DIR=/etc/php/8.1
                setup_php81_deb
            ;;

            "8.2")
                PHP_INI_DIR=/etc/php/8.2
                setup_php82_deb
            ;;

            "8.3")
                PHP_INI_DIR=/etc/php/8.3
                setup_php83_deb
            ;;

            "8.4")
                PHP_INI_DIR=/etc/php/8.4
                setup_php84_deb
            ;;

            *)
                echo "(!) PHP version ${PHP_VERSION} is not supported."
                exit 1
            ;;
        esac

        echo "export PHP_INI_DIR=${PHP_INI_DIR}" > /etc/profile.d/php_ini_dir.sh

        install -m 0644 php.ini "${PHP_INI_DIR}/cli/php.ini"
        install -m 0644 php.ini "${PHP_INI_DIR}/fpm/php.ini"
        # shellcheck disable=SC2016
        envsubst '$_REMOTE_USER' < www.conf.tpl > "${PHP_INI_DIR}/fpm/pool.d/www.conf"
        install -m 0644 -o root -g root docker.conf zz-docker.conf "${PHP_INI_DIR}/fpm/pool.d/"

        apt-get autoremove --purge -y
        apt-get clean
        rm -rf /var/lib/apt/lists/*
    ;;

    "alpine")
        PACKAGES=""
        if ! hash curl >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} curl"
        fi

        if ! hash envsubst >/dev/null 2>&1; then
            PACKAGES="${PACKAGES} gettext"
        fi

        if [ -n "${PACKAGES}" ]; then
            # shellcheck disable=SC2086
            apk add --no-cache ${PACKAGES}
        fi

        case "${PHP_VERSION}" in
            "8.0"|"8.1")
                PHP_VERSION="8.1"
                PHP_INI_DIR=/etc/php81
                setup_php81_alpine
            ;;

            "8.2")
                PHP_INI_DIR=/etc/php82
                setup_php82_alpine
            ;;

            "8.3")
                PHP_INI_DIR=/etc/php83
                setup_php83_alpine
            ;;

            "8.4")
                PHP_INI_DIR=/etc/php84
                setup_php84_alpine
            ;;

            *)
                echo "(!) PHP version ${PHP_VERSION} is not supported."
                exit 1
            ;;
        esac

        echo "export PHP_INI_DIR=${PHP_INI_DIR}" > /etc/profile.d/php_ini_dir.sh

        getent group www-data > /dev/null || addgroup -g 82 -S www-data
        getent passwd www-data > /dev/null || adduser -u 82 -D -S -G www-data -H www-data

        install -m 0644 php.ini "${PHP_INI_DIR}/php.ini"
        # shellcheck disable=SC2016
        envsubst '$_REMOTE_USER' < www.conf.tpl > "${PHP_INI_DIR}/php-fpm.d/www.conf"
        install -m 0644 -o root -g root docker.conf zz-docker.conf "${PHP_INI_DIR}/php-fpm.d/"
    ;;

    *)
        echo "(!) Unsupported distribution: ${ID}"
        exit 1
esac

pecl update-channels
rm -rf /tmp/pear ~/.pearrc

install -d -m 0750 -o "${_REMOTE_USER}" -g adm /var/log/php-fpm

if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
    install -D -d -m 0755 -o root -g root /etc/service /etc/sv/php-fpm
    # shellcheck disable=SC2016
    envsubst '$_REMOTE_USER' < service-run.tpl > /etc/sv/php-fpm/run
    chmod 0755 /etc/sv/php-fpm/run
    ln -sf /etc/sv/php-fpm /etc/service/php-fpm
fi

if [ -d /var/lib/entrypoint.d ]; then
    # shellcheck disable=SC2016
    envsubst '$_REMOTE_USER' < entrypoint.tpl > /var/lib/entrypoint.d/50-php-fpm
    chmod 0755 /var/lib/entrypoint.d/50-php-fpm
fi

if [ "${COMPOSER}" = "true" ]; then
    curl -SLo composer-setup.php https://getcomposer.org/installer
    HASH="$(curl -SL https://composer.github.io/installer.sig)"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '${HASH}') { echo 'Installer verified', PHP_EOL; } else { echo 'Installer corrupt', PHP_EOL; unlink('composer-setup.php'); exit(1); }"
    php composer-setup.php --install-dir="/usr/local/bin" --filename=composer
    rm -f composer-setup.php
fi

install -d /etc/dev-env-features
echo "${PHP_VERSION}" > /etc/dev-env-features/php
echo 'Done!'
