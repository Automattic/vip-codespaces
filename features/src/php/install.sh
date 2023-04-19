#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

setup_php74() {
    if ! grep -Eq '^@edgem' /etc/apk/repositories; then
        echo "@edgem https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
    fi

    if ! grep -Eq '^@edget' /etc/apk/repositories; then
        echo "@edget https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    fi

    apk add --no-cache \
        libssl3@edgem icu-libs@edgem icu-data-full@edgem ghostscript \
        php7@edget php7-fpm@edget php7-pear@edget \
        php7-pecl-apcu@edget \
        php7-bcmath@edget \
        php7-calendar@edget \
        php7-ctype@edget \
        php7-curl@edget \
        php7-dom@edget \
        php7-exif@edget \
        php7-fileinfo@edget \
        php7-ftp@edget \
        php7-gd@edget \
        php7-pecl-gmagick@edget \
        php7-gmp@edget \
        php7-iconv@edget \
        php7-intl@edget \
        php7-json@edget \
        php7-mbstring@edget \
        php7-pecl-mcrypt@edget \
        php7-pecl-memcache@edget \
        php7-pecl-memcached@edget \
        php7-mysqli@edget \
        php7-mysqlnd@edget \
        php7-opcache@edget \
        php7-openssl@edget \
        php7-pcntl@edget \
        php7-pdo@edget \
        php7-pdo_sqlite@edget \
        php7-phar@edget \
        php7-posix@edget \
        php7-session@edget \
        php7-shmop@edget \
        php7-simplexml@edget \
        php7-soap@edget \
        php7-sockets@edget \
        php7-sodium@edget \
        php7-sqlite3@edget \
        php7-pecl-ssh2@edget \
        php7-sysvsem@edget \
        php7-sysvshm@edget \
        php7-pecl-timezonedb@edget \
        php7-tokenizer@edget \
        php7-xml@edget \
        php7-xmlreader@edget \
        php7-xmlwriter@edget \
        php7-zip@edget

    ln -s /usr/sbin/php-fpm7 /usr/sbin/php-fpm
    ln -s /usr/bin/php7 /usr/bin/php
    ln -s /usr/bin/pecl7 /usr/bin/pecl
    ln -s /usr/bin/pear7 /usr/bin/pear
    ln -s /usr/bin/peardev7 /usr/bin/peardev
    ln -s /usr/bin/phar7 /usr/bin/phar
    ln -s /usr/bin/phar7.phar /usr/bin/phar.phar
}

setup_php80() {
    if ! grep -Eq '^@edgem' /etc/apk/repositories; then
        echo "@edgem https://dl-cdn.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories
    fi

    if ! grep -Eq '^@edget' /etc/apk/repositories; then
        echo "@edget https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    fi

    apk add --no-cache \
        icu-data-full@edgem icu-libs@edgem libssl3@edgem ghostscript \
        php8@edget \
        php8-fpm@edget \
        php8-pear@edget \
        php8-pecl-apcu@edget \
        php8-bcmath@edget \
        php8-calendar@edget \
        php8-ctype@edget \
        php8-curl@edget \
        php8-dom@edget \
        php8-exif@edget \
        php8-fileinfo@edget \
        php8-ftp@edget \
        php8-gd@edget \
        php8-pecl-gmagick@edget \
        php8-gmp@edget \
        php8-iconv@edget \
        php8-intl@edget \
        php8-json@edget \
        php8-mbstring@edget \
        php8-pecl-igbinary@edget \
        php8-pecl-mcrypt@edget \
        php8-pecl-memcache@edget \
        php8-pecl-memcached@edget \
        php8-mysqli@edget \
        php8-mysqlnd@edget \
        php8-opcache@edget \
        php8-openssl@edget \
        php8-pcntl@edget \
        php8-pdo@edget \
        php8-pdo_sqlite@edget \
        php8-phar@edget \
        php8-posix@edget \
        php8-session@edget \
        php8-shmop@edget \
        php8-simplexml@edget \
        php8-soap@edget \
        php8-sockets@edget \
        php8-sodium@edget \
        php8-sqlite3@edget \
        php8-pecl-ssh2@edget \
        php8-sysvsem@edget \
        php8-sysvshm@edget \
        php8-pecl-timezonedb@edget \
        php8-tokenizer@edget \
        php8-xml@edget \
        php8-xmlreader@edget \
        php8-xmlwriter@edget \
        php8-zip@edget

    [ ! -f /usr/sbin/php-fpm ] && ln -s /usr/sbin/php-fpm8 /usr/sbin/php-fpm
    [ ! -f /usr/bin/php ] && ln -s /usr/bin/php8 /usr/bin/php
    [ ! -f /usr/bin/pecl ] && ln -s /usr/bin/pecl8 /usr/bin/pecl
    [ ! -f /usr/bin/pear ] && ln -s /usr/bin/pear8 /usr/bin/pear
    [ ! -f /usr/bin/peardev ] && ln -s /usr/bin/peardev8 /usr/bin/peardev
    [ ! -f /usr/bin/phar ] && ln -s /usr/bin/phar8 /usr/bin/phar
    [ ! -f /usr/bin/phar.phar ] && ln -s /usr/bin/phar8 /usr/bin/phar.phar
    true
}

setup_php81() {
    if ! grep -Eq '^@edgec' /etc/apk/repositories; then
        echo "@edgec https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
    fi

    if ! grep -Eq '^@edget' /etc/apk/repositories; then
        echo "@edget https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    fi

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
        php81-pecl-mcrypt@edget \
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
        php81-pecl-timezonedb@edget \
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
    if ! grep -Eq '^@edgec' /etc/apk/repositories; then
        echo "@edgec https://dl-cdn.alpinelinux.org/alpine/edge/community" >> /etc/apk/repositories
    fi

    if ! grep -Eq '^@edget' /etc/apk/repositories; then
        echo "@edget https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories
    fi

    apk add --no-cache \
        icu-data-full ghostscript \
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
        php82-pecl-memcache@edget \
        php82-pecl-memcached@edgec \
        php82-pecl-mcrypt@edget \
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
        php82-pecl-timezonedb@edget \
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

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${VERSION:?}"
: "${COMPOSER:=}"

echo "(*) Installing PHP ${VERSION}..."
case "${VERSION}" in
    "7.4")
        setup_php74
        PHP_INI_DIR=/etc/php7
        echo "export PHP_INI_DIR=/etc/php7" > /etc/profile.d/php_ini_dir.sh
        ln -sf /etc/php7 /etc/php
    ;;

    "8.0")
        setup_php80
        echo "export PHP_INI_DIR=/etc/php8" > /etc/profile.d/php_ini_dir.sh
        PHP_INI_DIR=/etc/php8
        ln -sf /etc/php8 /etc/php
    ;;

    "8.1")
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
