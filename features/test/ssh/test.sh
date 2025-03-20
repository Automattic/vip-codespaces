#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "sshd exists" which sshd
check "/etc/sv/openssh/run exists and is executable" test -x /etc/sv/openssh/run
check "/etc/service/openssh is a symlink" test -L /etc/service/openssh

if [[ "$(id -u || true)" -eq 0 ]]; then
    check "/etc/ssh/sshd_config.d/permit_root_login.conf exists" test -f /etc/ssh/sshd_config.d/permit_root_login.conf
fi

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/ssh/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/ssh/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/ssh/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/ssh/devcontainer-features.env

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
