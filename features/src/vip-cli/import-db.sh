#!/bin/sh

set -e

if [ -z "${VIP_CLI_TOKEN}" ]; then
    echo "✕ Error: VIP CLI token is not set. Please set VIP_CLI_TOKEN environment variable (via Codespaces Secrets)."
    exit 1
fi

if [ -z "${VIP_APP}" ]; then
    echo "✕ Error: VIP_APP environment variable is not set."
    exit 1
fi

if [ ! -f ~/.config/configstore/vip-go-cli.json ]; then
    mkdir -p ~/.config/configstore
    echo "${VIP_CLI_TOKEN}" > ~/.config/configstore/vip-go-cli.json
else
    echo "$⚠️ {HOME}/.config/configstore/vip-go-cli.json already exists, not updating."
fi

# We cannot use `vip whoami` to check if the user is logged in: its exit status is always 0 :-()

echo "ℹ️ Exporting the database…"
vip export sql "${VIP_APP}" --output=/tmp/export.sql.gz
if [ ! -f /tmp/export.sql ]; then
    echo "✕ Unable to export the database from VIP."
fi

echo "ℹ️ Extracting archive…"
gunzip /tmp/export.sql.gz

echo "ℹ️ Retrieving site URL…"
DEST_URL="$(wp option get home)"

echo "ℹ️ Importing database dump…"
wp db import /tmp/export.sql
rm -f /tmp/export.sql

echo "ℹ️ Retrieving URL to replace…"
SRC_URL="$(wp option get home)"

echo "ℹ️ Replacing ${SRC_URL} with ${DEST_URL}…"
wp search-replace "${SRC_URL}" "${DEST_URL}" --all-tables --recurse-objects

echo "ℹ️ Flushing cache…"
wp cache flush

echo "✓ Done!"
