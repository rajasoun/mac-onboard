#!/usr/bin/env bash

# Fail on Error
# set -euo pipefail
# IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/display.sh"
source "$SCRIPT_DIR/lib/teardown.sh"
source "$SCRIPT_DIR/lib/setup.sh"
source "$SCRIPT_DIR/lib/e2e_tests.sh"


opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case ${choice} in
    "setup")setup_main ;;
    "test")e2e_tests_main ;;
    "teardown")teardown_main ;;
    "check") check_integrity ;;
    *)
    echo "${RED}Usage: e2e.sh < setup | test | teardown >${NC}"
cat <<-EOF
Commands:
---------
  setup       -> Setup Mac
  test        -> Run Automated Test 
  teardown    -> Teardown Dev Container
EOF
    ;;
esac