#!/usr/bin/env bash

opt="$1"
choice=$( tr '[:upper:]' '[:lower:]' <<<"$opt" )

case ${choice} in
    "setup")lib/e2e.sh && echo "Result: $?";;
    "test")lib/e2e_tests.sh ;;
    "teardown")lib/teardown.sh ;;
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