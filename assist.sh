#!/usr/bin/env bash

# Fail on Error
# set -euo pipefail
# IFS=$'\n\t'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR=$(dirname "$0")

source "$SCRIPT_DIR/lib/display.sh"
source "$SCRIPT_DIR/lib/git.sh"
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
    "drift-check") check_drift ;;
    "git-config")git_config_main;;
    "git-login")
      gh auth login --hostname $GIT --git-protocol ssh --with-token < github.token
      gh auth status  
      ;;
    "brew-upgrade")
      brew update
      brew upgrade 
      backup_copy_dotfile .setup
      audit_trail
      ;;
    "update-audit-trail")
      update_audit_trail
      ;;
    *)
    echo "${RED}Usage: $0 < setup | test | teardown >${NC}"
cat <<-EOF
Commands:
---------
  pre-checks          -> Perform Pre-requisites Checks
  setup               -> Setup Mac
  speed-test          -> Speed Test using Docker
  test                -> Run Automated Test
  teardown            -> Teardown Dev Container
  drift-check         -> Check Drift of the automated setup
  git-config          -> Git Configuration
  git-login           -> Git Login
  brew-upgrade        -> Homebrew Upgrade
  update-audit-trail  -> Update Audit Trail 
EOF
    ;;
esac
