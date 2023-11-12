#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

setup_php81() {
    apk add --no-cache \
        icu-data-full ghostscript \
        php81 php81-fpm php81-pear \
        php81-pecl-apcu \
        php81-bcmath \
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
        php81-intl \
        php81-json \
        php81-mbstring \
        php81-pecl-igbinary@edgec \
        php81-pecl-mcrypt@edgec \
        php81-pecl-memcache \
        php81-pecl-memcached \
        php81-mysqli \
        php81-mysqlnd \
        php81-opcache \
        php81-openssl \
        php81-pcntl \
        php81-pdo \
        php81-pdo_sqlite \
        php81-phar \
        php81-posix \
        php81-session \
        php81-shmop \
        php81-simplexml \
        php81-soap \
        php81-sockets \
        php81-sodium \
        php81-sqlite3 \
        php81-pecl-ssh2 \
        php81-sysvsem \
        php81-sysvshm \
        php81-pecl-timezonedb@edgec \
        php81-tokenizer \
        php81-xml \
        php81-xmlreader \
        php81-xmlwriter \
        php81-zip

    apk add --no-cache php81-dev gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp
    pecl81 channel-update pecl.php.net
    pecl81 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
    apk del --no-cache php81-dev gcc make libc-dev graphicsmagick-dev libtool

    echo "extension=gmagick.so" > /etc/php81/conf.d/40_gmagick.ini

    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm81 /usr/sbin/php-fpm
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php81 /usr/bin/php
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl81 /usr/bin/pecl
    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear81 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev81 /usr/bin/peardev
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar81 /usr/bin/phar
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar81 /usr/bin/phar.phar
    true
}

setup_php82() {
    apk add --no-cache \
        icu-data-full icu-libs@edgem libavif@edgem libsodium@edgem ghostscript \
        php82@edgec php82-fpm@edgec php82-pear@edgec \
        php82-pecl-apcu@edgec \
        php82-bcmath@edgec \
        php82-calendar@edgec \
        php82-ctype@edgec \
        php82-curl@edgec \
        php82-dom@edgec \
        php82-exif@edgec \
        php82-fileinfo@edgec \
        php82-ftp@edgec \
        php82-gd@edgec \
        php82-gmp@edgec \
        php82-iconv@edgec \
        php82-intl@edgec \
        php82-mbstring@edgec \
        php82-pecl-igbinary@edgec \
        php82-pecl-memcache@edgec \
        php82-pecl-memcached@edgec \
        php82-pecl-mcrypt@edgec \
        php82-mysqli@edgec \
        php82-mysqlnd@edgec \
        php82-opcache@edgec \
        php82-openssl@edgec \
        php82-pcntl@edgec \
        php82-pdo@edgec \
        php82-pdo_sqlite@edgec \
        php82-phar@edgec \
        php82-posix@edgec \
        php82-session@edgec \
        php82-shmop@edgec \
        php82-simplexml@edgec \
        php82-soap@edgec \
        php82-sockets@edgec \
        php82-sodium@edgec \
        php82-sqlite3@edgec \
        php82-sysvsem@edgec \
        php82-sysvshm@edgec \
        php82-pecl-timezonedb@edgec \
        php82-tokenizer@edgec \
        php82-xml@edgec \
        php82-xmlreader@edgec \
        php82-xmlwriter@edgec \
        php82-zip@edgec

    # Missing: php82-pecl-ssh2

    apk add --no-cache php82-dev@edgec gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp
    pecl82 channel-update pecl.php.net
    pecl82 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
    apk del --no-cache php82-dev gcc make libc-dev graphicsmagick-dev libtool

    echo "extension=gmagick.so" > /etc/php82/conf.d/40_gmagick.ini

    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm82 /usr/sbin/php-fpm
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php82 /usr/bin/php
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl82 /usr/bin/pecl
    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear82 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev82 /usr/bin/peardev
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar82 /usr/bin/phar
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar82 /usr/bin/phar.phar
    true
}

setup_php83() {
    apk add --no-cache \
        icu-data-full icu-libs@edgem libavif@edgem libsodium@edgem ghostscript \
        php83@edget php83-fpm@edget php83-pear@edget \
        php83-pecl-apcu@edget \
        php83-bcmath@edget \
        php83-calendar@edget \
        php83-ctype@edget \
        php83-curl@edget \
        php83-dom@edget \
        php83-exif@edget \
        php83-fileinfo@edget \
        php83-ftp@edget \
        php83-gd@edget \
        php83-gmp@edget \
        php83-iconv@edget \
        php83-intl@edget \
        php83-mbstring@edget \
        php83-pecl-igbinary@edget \
        php83-mysqli@edget \
        php83-mysqlnd@edget \
        php83-opcache@edget \
        php83-openssl@edget \
        php83-pcntl@edget \
        php83-pdo@edget \
        php83-pdo_sqlite@edget \
        php83-phar@edget \
        php83-posix@edget \
        php83-session@edget \
        php83-shmop@edget \
        php83-simplexml@edget \
        php83-soap@edget \
        php83-sockets@edget \
        php83-sodium@edget \
        php83-sqlite3@edget \
        php83-sysvsem@edget \
        php83-sysvshm@edget \
        php83-tokenizer@edget \
        php83-xml@edget \
        php83-xmlreader@edget \
        php83-xmlwriter@edget \
        php83-zip@edget

    # Missing: php83-pecl-ssh2 php83-pecl-timezonedb php83-pecl-memcache php83-pecl-memcached php83-pecl-mcrypt

    apk add --no-cache php83-dev@edget gcc make libc-dev graphicsmagick-dev libtool graphicsmagick libgomp libmemcached libmemcached-dev
    pecl83 channel-update pecl.php.net
    pecl83 install channel://pecl.php.net/gmagick-2.0.6RC1 < /dev/null || true
    pecl83 install memcache < /dev/null || true
    pecl83 install memcached < /dev/null || true
    pecl83 install timezonedb < /dev/null || true

    apk del --no-cache php83-dev gcc make libc-dev graphicsmagick-dev libtool libmemcached-dev

    echo "extension=gmagick.so" > /etc/php83/conf.d/40_gmagick.ini
    echo "extension=memcache.so" > /etc/php83/conf.d/40_memcache.ini
    echo "extension=memcached.so" > /etc/php83/conf.d/40_memcached.ini
    echo "extension=timezonedb.so" > /etc/php83/conf.d/40_timezonedb.ini

    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm83 /usr/sbin/php-fpm
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php83 /usr/bin/php
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl83 /usr/bin/pecl
    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear83 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev83 /usr/bin/peardev
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar83 /usr/bin/phar
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar83 /usr/bin/phar.phar
    true
}

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${VERSION:?}"
: "${COMPOSER:=}"

echo "(*) Installing PHP ${VERSION}..."
case "${VERSION}" in
    "8.0"|"8.1")
        VERSION="8.1"
        setup_php81
        echo "export PHP_INI_DIR=/etc/php81" > /etc/profile.d/php_ini_dir.sh
        PHP_INI_DIR=/etc/php81
        ln -sf /etc/php81 /etc/php
    ;;

    "8.2")
        setup_php82
        echo "export PHP_INI_DIR=/etc/php82" > /etc/profile.d/php_ini_dir.sh
        PHP_INI_DIR=/etc/php82
        ln -sf /etc/php82 /etc/php
    ;;

    "8.3")
        setup_php83
        echo "export PHP_INI_DIR=/etc/php83" > /etc/profile.d/php_ini_dir.sh
        PHP_INI_DIR=/etc/php83
        ln -sf /etc/php83 /etc/php
    ;;

    *)
        echo "(!) PHP version ${VERSION} is not supported."
        exit 1
    ;;
esac

getent group www-data > /dev/null || addgroup -g 82 -S www-data
getent passwd www-data > /dev/null || adduser -u 82 -D -S -G www-data -H www-data

pecl update-channels
rm -rf /tmp/pear ~/.pearrc

install -m 0644 php.ini "${PHP_INI_DIR}/php.ini"
if [ -z "${_REMOTE_USER}" ] || [ "${_REMOTE_USER}" = "root" ]; then
    PHP_USER="www-data"
else
    PHP_USER="${_REMOTE_USER}"
fi

export PHP_USER
# shellcheck disable=SC2016
envsubst '$PHP_USER' < www.conf.tpl > "${PHP_INI_DIR}/php-fpm.d/www.conf"
install -d -m 0750 -o "${PHP_USER}" -g adm /var/log/php-fpm
install -m 0644 -o root -g root docker.conf zz-docker.conf "${PHP_INI_DIR}/php-fpm.d/"
install -D -m 0755 -o root -g root service-run /etc/sv/php-fpm/run
install -d -m 0755 -o root -g root /etc/service
ln -sf /etc/sv/php-fpm /etc/service/php-fpm

if [ "${COMPOSER}" = "true" ]; then
    wget -q https://getcomposer.org/installer -O composer-setup.php
    HASH="$(wget -q -O - https://composer.github.io/installer.sig)"
    php -r "if (hash_file('sha384', 'composer-setup.php') === '${HASH}') { echo 'Installer verified', PHP_EOL; } else { echo 'Installer corrupt', PHP_EOL; unlink('composer-setup.php'); exit(1); }"
    php composer-setup.php --install-dir="/usr/local/bin" --filename=composer
    rm -f composer-setup.php
fi

install -d /etc/dev-env-features
echo "${VERSION}" > /etc/dev-env-features/php
echo 'Done!'
