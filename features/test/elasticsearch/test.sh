#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "elasticsearch exists" which elasticsearch
if [[ -d /etc/sv ]]; then
    check "/etc/sv/elasticsearch/run exists and is executable" test -x /etc/sv/elasticsearch/run
    check "/etc/service/elasticsearch is a symlink" test -L /etc/service/elasticsearch
fi

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/elasticsearch/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/elasticsearch/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/elasticsearch/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/elasticsearch/devcontainer-features.env

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
