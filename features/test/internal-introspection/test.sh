#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "/usr/local/bin/internal-introspection-ep.sh exists and is executable" test -x /usr/local/bin/internal-introspection-ep.sh
check "/usr/local/bin/internal-introspection-on-create.sh exists and is executable" test -x /usr/local/bin/internal-introspection-on-create.sh
check "/usr/local/bin/internal-introspection-post-create.sh exists and is executable" test -x /usr/local/bin/internal-introspection-post-create.sh
check "/usr/local/bin/internal-introspection-post-start.sh exists and is executable" test -x /usr/local/bin/internal-introspection-post-start.sh
check "/usr/local/bin/internal-introspection-post-attach.sh exists and is executable" test -x /usr/local/bin/internal-introspection-post-attach.sh
check "/usr/local/bin/internal-introspection-update-content.sh exists and is executable" test -x /usr/local/bin/internal-introspection-update-content.sh

for i in /usr/local/etc/vscode-dev-containers/vip-codespaces/internal-introspection/*.env; do
    echo "=== ${i}"
    cat "${i}"
    echo
done

reportResults
