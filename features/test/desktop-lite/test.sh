#!/bin/bash

#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "openbox exists" which openbox
check "Xtigervnc exists" which Xtigervnc
check "easy-novnc exists" which easy-novnc

check "DISPLAY is set" test -n "${DISPLAY}"

if [[ -d /etc/sv ]]; then
    check "/etc/sv/tigervnc/run exists and is executable" test -x /etc/sv/tigervnc/run
    check "/etc/service/tigervnc exists and is a symlink" test -L /etc/service/tigervnc

    check "/etc/sv/novnc/run exists and is executable" test -x /etc/sv/novnc/run
    check "/etc/service/novnc exists and is a symlink" test -L /etc/service/novnc

    check "/etc/sv/openbox/run exists and is executable" test -x /etc/sv/openbox/run
    check "/etc/service/openbox exists and is a symlink" test -L /etc/service/openbox
fi

check "/usr/local/etc/vscode-dev-containers/vip-codespaces/desktop-lite/devcontainer-feature.json exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/desktop-lite/devcontainer-feature.json
check "/usr/local/etc/vscode-dev-containers/vip-codespaces/desktop-lite/devcontainer-features.env exists" test -f /usr/local/etc/vscode-dev-containers/vip-codespaces/desktop-lite/devcontainer-features.env

# Microsoft's base images contain zsh. We don't want to run this check for MS images because we have no control over the installed services.
if test -d /etc/rc2.d && ! test -e /usr/bin/zsh; then
    dir="$(ls -1 /etc/rc2.d)"
    ls -1 /etc/rc2.d
    check "/etc/rc2.d is empty" test -z "${dir}"
fi

reportResults
