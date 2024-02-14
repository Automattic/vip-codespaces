#!/bin/bash

# shellcheck source=/dev/null
source dev-container-features-test-lib

check "su-exec exists" sh -c "which su-exec"

reportResults
