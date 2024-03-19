FROM wordpress:php8.3

RUN \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends mariadb-client libmemcached-dev libssl-dev zlib1g-dev iputils-ping telnet && \
    pecl install memcached-3.2.0 && \
    docker-php-ext-enable memcached && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chown=www-data:www-data rootfs /
