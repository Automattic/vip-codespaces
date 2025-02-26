#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
SSHD_PORT="${PORT:-22}"
: "${NEW_PASSWORD:=skip}"

if [ "${ENABLED:-}" = "true" ]; then
    echo '(*) Installing OpenSSH server...'

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"
    PRIVSEP_DIR=

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            apt-get update
            apt-get install -y --no-install-recommends openssh-server openssl
            apt-get clean
            rm -rf /var/lib/apt/lists/*
            update-rc.d -f ssh remove
            PRIVSEP_DIR=/run/sshd
            sed -i 's/session\s*required\s*pam_loginuid\.so/session optional pam_loginuid.so/g' /etc/pam.d/sshd
        ;;

        "alpine")
            apk upgrade --no-cache 'openssh*' openssl
            # shellcheck disable=SC2086
            apk add --no-cache openssh-server-pam openssl
            ln -sf /usr/sbin/sshd.pam /usr/sbin/sshd
            rm -f /etc/conf.d/sshd /etc/init.d/sshd
            PRIVSEP_DIR=/var/empty
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
    esac

    if [ "${NEW_PASSWORD}" = "random" ]; then
        NEW_PASSWORD="$(openssl rand -hex 24)"
        echo "(!) Random password for ${_REMOTE_USER}: ${NEW_PASSWORD}"
    elif [ "${NEW_PASSWORD}" != "skip" ]; then
        echo "${_REMOTE_USER}:${NEW_PASSWORD}" | chpasswd
    fi

    install -m 0644 -o root -g root sshd_config /etc/ssh/sshd_config
    install -D -d -m 0555 -o root -g root "${PRIVSEP_DIR}"
    install -d -m 0755 -o root -g root /etc/service
    install -D -m 0755 -o root -g root service-run /etc/sv/openssh/run
    ln -sf /etc/sv/openssh /etc/service/openssh

    if [ "${_REMOTE_USER}" = 'root' ]; then
        echo 'PermitRootLogin=yes' > /etc/ssh/sshd_config.d/permit_root_login.conf
    fi

    echo "Port=${SSHD_PORT}" > /etc/ssh/sshd_config.d/listen_port.conf

    echo 'Done!'
fi
