#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "wp-cli exists" sh -c "[ -x /usr/local/bin/wp ]"

reportResults
