#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

ME=$(whoami)

check "nginx exists" which nginx
check "nginx can run" nginx -V
if [[ "${ME}" = 'root' ]]; then
    check "nginx configuration is valid" nginx -t
else
    check "nginx configuration is valid" sudo nginx -t
fi

if [[ -d /etc/sv ]]; then
    check "/etc/sv/nginx/run exists and is executable" test -x /etc/sv/nginx/run
    check "/etc/service/nginx is a symlink" test -L /etc/service/nginx
fi

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/nginx/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/nginx/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/nginx/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/nginx/devcontainer-features.env

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
