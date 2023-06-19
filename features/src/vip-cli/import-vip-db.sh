#!/bin/sh

set -e

if [ -n "${VIP_CLI_TOKEN}" ] && [ ! -f ~/.config/configstore/vip-go-cli.json ]; then
    echo "ℹ️ Using VIP_CLI_TOKEN to authenticate with VIP."
    mkdir -p ~/.config/configstore
    echo "${VIP_CLI_TOKEN}" > ~/.config/configstore/vip-go-cli.json
fi

out="$(vip whoami </dev/null 2>/dev/null)"
if ! echo "${out}" | grep -Eq "^- Howdy "; then
    echo "⚠️ You are not logged in to VIP."
    vip login
fi

out="$(vip whoami </dev/null 2>/dev/null)"
if ! echo "${out}" | grep -Eq "^- Howdy "; then
    echo "✕ Unable to log in to VIP. Please try again."
    exit 1
fi

name="$(echo "${out}" | sed -n 's/^- Howdy //; s/!//; p; q')"
uid="$(echo "${out}" | awk '/^- Your user ID is/ { print $6 }')"
echo "✓ Logged in as ${name} (${uid})"

if [ -n "${VIP_APP_ID}" ]; then
    if [ "${VIP_APP_ID}" = "${VIP_APP_ID#@}" ]; then
        VIP_APP_ID="@${VIP_APP_ID}"
    fi

    echo "ℹ️ Using VIP_APP_ID (${VIP_APP_ID}) to select the application."
fi

echo "ℹ️ Exporting the database…"
# shellcheck disable=SC2086
vip export sql ${VIP_APP_ID} --output=/tmp/export.sql.gz
if [ ! -f /tmp/export.sql.gz ]; then
    echo "✕ Unable to export the database from VIP."
    exit 1
fi

echo "ℹ️ Extracting archive…"
gunzip -f /tmp/export.sql.gz

echo "ℹ️ Retrieving site URL…"
DEST_URL="$(wp option get home)"

echo "ℹ️ Importing database dump…"
wp db import /tmp/export.sql
rm -f /tmp/export.sql

echo "ℹ️ Flushing cache…"
wp cache flush

echo "ℹ️ Retrieving URL to replace…"
SRC_URL="$(wp option get home)"

echo "ℹ️ Replacing ${SRC_URL} with ${DEST_URL}…"
wp search-replace "${SRC_URL}" "${DEST_URL}" --all-tables --recurse-objects

echo "ℹ️ Flushing cache…"
wp cache flush

echo "✓ Done!"
