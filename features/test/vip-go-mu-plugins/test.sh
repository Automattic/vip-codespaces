#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "rsync is executable" which rsync
check "git is executable" which git
check "/wp/wp-content/mu-plugins is a directory" test -d /wp/wp-content/mu-plugins

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/vip-go-mu-plugins/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/vip-go-mu-plugins/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/vip-go-mu-plugins/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/vip-go-mu-plugins/devcontainer-features.env

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
