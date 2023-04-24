#!/bin/sh

set -ex

if [ -z "$1" ]; then
    echo "Usage: $0 <devcontainer.json>"
    exit 1
fi

mkdir -p .devcontainer/features
rsync -a --delete ../features/src/* .devcontainer/features
sed -i 's!ghcr.io/automattic/vip-codespaces/!./.devcontainer/features/!' .devcontainer/features/*/devcontainer-feature.json

export BUILDKIT_PROGRESS=plain
devcontainer build --config "$1" --workspace-folder .
