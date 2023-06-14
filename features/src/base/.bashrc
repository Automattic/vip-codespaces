# shellcheck shell=bash

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

if [ -d "${HOME}/.local/share/vip-codespaces/login" ] && [ -n "$(ls -A "${HOME}/.local/share/vip-codespaces/login")" ]; then
    for f in "${HOME}"/.local/share/vip-codespaces/login/*; do
        # shellcheck source=/dev/null
        [ -f "${f}" ] && source "${f}"
    done
fi
