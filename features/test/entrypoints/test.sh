#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "/var/lib/entrypoint.d exists" test -d /var/lib/entrypoint.d
check "/usr/local/bin/entrypoint-runner exists and is executable" test -x /usr/local/bin/entrypoint-runner

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/entrypoints/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/entrypoints/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/entrypoints/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/entrypoints/devcontainer-features.env

reportResults
