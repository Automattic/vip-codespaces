#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "php exists" which php
check "php-fpm exists" which php-fpm
check "pecl exists" which pecl
check "pear exists" which pear
check "composer exists" which composer
check "www-data user exists" getent passwd www-data
check "www-data group exists" getent group www-data

MODULES="apcu bcmath calendar ctype curl date dom exif fileinfo filter ftp gd gmagick gmp hash iconv igbinary intl json libxml mbstring mcrypt memcache memcached mysqli mysqlnd openssl pcntl pcre pdo_mysql pdo_sqlite phar posix random reflection session shmop simplexml soap sockets sodium sqlite3 ssh2 sysvsem sysvshm timezonedb tokenizer xml xmlreader xmlwriter zip zlib"
for module in ${MODULES}; do
    check "PHP module ${module} exists" sh -c "php -m | grep -qi ^${module}$"
done

check "composer version" composer --version

ME="$(whoami)"
if [[ "${ME}" = 'root' ]]; then
    check "php-fpm configuration is valid" php-fpm -t
else
    check "php-fpm configuration is valid" sudo php-fpm -t
fi

if [[ -d /etc/sv ]]; then
    check "/etc/sv/php-fpm/run exists and is executable" test -x /etc/sv/php-fpm/run
    check "/etc/service/php-fpm is a symlink" test -L /etc/service/php-fpm
fi

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/php/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/php/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/php/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/php/devcontainer-features.env

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
