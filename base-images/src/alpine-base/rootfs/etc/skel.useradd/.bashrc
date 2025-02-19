# shellcheck shell=bash
# shellcheck source=/dev/null
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path bash)"
