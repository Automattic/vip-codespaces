#!/bin/sh

set -e

PATH=/usr/local/bin:/usr/local/sbin:/bin:/sbin:/usr/bin:/usr/sbin

if [ "$(id -u || true)" -ne 0 ]; then
    echo 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

: "${_REMOTE_USER:?"_REMOTE_USER is required"}"
: "${ENABLED:=}"
: "${VNC_GEOMETRY:="1280x800"}"
: "${VNC_PASSWORD:=""}"
: "${INSTALL_RUNIT_SERVICE:=true}"

if [ "${ENABLED}" = "true" ]; then
    echo '(*) Installing Lightweight Desktop...'

    install -d -D -m 0755 /usr/local/etc/vscode-dev-containers/vip-codespaces/desktop-lite
    install -m 0644 devcontainer-feature.json devcontainer-features.env /usr/local/etc/vscode-dev-containers/vip-codespaces/desktop-lite/

    # shellcheck source=/dev/null
    . /etc/os-release

    : "${ID:=}"
    : "${ID_LIKE:=${ID}}"

    case "${ID_LIKE}" in
        "debian")
            export DEBIAN_FRONTEND=noninteractive
            PACKAGES=""

            apt-get update

            if ! hash curl >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} curl"
            fi

            if ! hash update-ca-certificates >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} ca-certificates"
            fi

            if ! hash openbox >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} openbox"
            fi

            if ! hash obconf >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} obconf"
            fi

            if ! hash Xtigervnc >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} tigervnc-standalone-server"
            fi

            if ! hash tigervncpasswd >/dev/null 2>&1 && [ -n "$(apt-cache --names-only search '^tigervnc-tools$' || true)" ]; then
                PACKAGES="${PACKAGES} tigervnc-tools"
            fi

            if ! hash envsubst >/dev/null 2>&1; then
                PACKAGES="${PACKAGES} gettext"
            fi

            if [ -n "${PACKAGES}" ]; then
                # shellcheck disable=SC2086
                apt-get install -y --no-install-recommends ${PACKAGES}
                apt-get clean

                update-rc.d -f dbus remove
            fi

            rm -rf /var/lib/apt/lists/*
        ;;

        *)
            echo "(!) Unsupported distribution: ${ID}"
            exit 1
        ;;
    esac

    HOME_DIR="$(getent passwd "${_REMOTE_USER}" | cut -d: -f6)"
    install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.config"
    install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.config/openbox"
    install -m 0644 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" menu.xml "${HOME_DIR}/.config/openbox/menu.xml"
    install -d -m 0755 -o "${_REMOTE_USER}" -g "${_REMOTE_USER}" "${HOME_DIR}/.vnc"

    ARCH="$(arch)"
    if [ "${ARCH}" = "arm64" ] || [ "${ARCH}" = "aarch64" ]; then
        ARCH="arm"
    elif [ "${ARCH}" = "x86_64" ] || [ "${ARCH}" = "amd64" ]; then
        ARCH="64bit"
    else
        echo "(!) Unsupported architecture: ${ARCH}"
        exit 1
    fi

    curl -SL "https://github.com/pgaskin/easy-novnc/releases/download/v1.1.0/easy-novnc_linux-64bit" -o /usr/local/bin/easy-novnc
    chmod 0755 /usr/local/bin/easy-novnc

    if [ -n "${VNC_PASSWORD}" ]; then
        echo "${VNC_PASSWORD}" | tigervncpasswd -f > "${HOME_DIR}/.vnc/passwd"
        chmod 0600 "${HOME_DIR}/.vnc/passwd"
        chown "${_REMOTE_USER}:${_REMOTE_USER}" "${HOME_DIR}/.vnc/passwd"
    fi

    if [ -d /var/lib/entrypoint.d ]; then
        export VNC_GEOMETRY
        # shellcheck disable=SC2016
        envsubst '$VNC_GEOMETRY $_REMOTE_USER' < entrypoint.tpl > /var/lib/entrypoint.d/50-desktop-lite
        chmod 0755 /var/lib/entrypoint.d/50-desktop-lite
    fi

    if [ "${INSTALL_RUNIT_SERVICE}" = 'true' ] && [ -d /etc/sv ]; then
        install -D -d -m 0755 -o root -g root /etc/service /etc/sv/openbox /etc/sv/novnc /etc/sv/tigervnc
        export VNC_GEOMETRY
        # shellcheck disable=SC2016
        envsubst '$VNC_GEOMETRY $_REMOTE_USER' < service-run.tigervnc.tpl > /etc/sv/tigervnc/run

        # shellcheck disable=SC2016
        envsubst '$_REMOTE_USER' < service-run.openbox.tpl > /etc/sv/openbox/run

        # shellcheck disable=SC2016
        envsubst '$_REMOTE_USER' < service-run.novnc.tpl > /etc/sv/novnc/run

        chmod 0755 /etc/sv/tigervnc/run /etc/sv/openbox/run /etc/sv/novnc/run

        ln -sf /etc/sv/tigervnc /etc/service/tigervnc
        ln -sf /etc/sv/openbox /etc/service/openbox
        ln -sf /etc/sv/novnc /etc/service/novnc
    fi

    echo "Done!"
fi
