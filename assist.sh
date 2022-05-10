#!/usr/bin/env bash

# Fail on Error
# set -euo pipefail
# IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/lib/display.sh"
source "$SCRIPT_DIR/lib/teardown.sh"
source "$SCRIPT_DIR/lib/setup.sh"
source "$SCRIPT_DIR/lib/e2e_tests.sh"
source "$SCRIPT_DIR/lib/pre_checks.sh"

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case ${choice} in
    "pre-checks") pre_checks_main;;
    "setup")setup_main ;;
    "speed-test") speed_test;;
    "test")e2e_tests_main ;;
    "teardown")teardown_main ;;
    "check") check_drift ;;
    *)
    echo "${RED}Usage: e2e.sh < setup | test | teardown >${NC}"
cat <<-EOF
Commands:
---------
  pre-checks  -> Perform Pre-requisites Checks
  setup       -> Setup Mac
  speed-test  -> Speed Test using Docker
  test        -> Run Automated Test
  teardown    -> Teardown Dev Container
  check       -> Check Drift of the automated setup
EOF
    ;;
esac
