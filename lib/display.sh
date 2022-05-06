#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'

# Displays Time in misn and seconds
function _display_time {
  local T=$1
  local D=$((T / 60 / 60 / 24))
  local H=$((T / 60 / 60 % 24))
  local M=$((T / 60 % 60))
  local S=$((T % 60))
  ((D > 0)) && printf '%d days ' $D
  ((H > 0)) && printf '%d hours ' $H
  ((M > 0)) && printf '%d minutes ' $M
  ((D > 0 || H > 0 || M > 0)) && printf 'and '
  printf '%d seconds\n' $S
}

# Displays Message
function log(){
  EXIT_CODE="$1"
  MESSAGE="$2"
  if [[ -n "$EXIT_CODE" && "$EXIT_CODE" -eq 0 ]]; then
    echo -e "${GREEN}$MESSAGE | Success ✅${NC}"
  else
    echo -e "${RED}$MESSAGE | Failed ❌${NC}"
  fi
}

function pretty_print() {
  printf "\n%b\n" "$1"
}

function echoStderr(){
    echo "$@" 1>&2
}

function log_sentry() {
  EXIT_CODE="$1"
  MESSAGE="$2"
  GIT_VERSION=$(git describe --tags --always --dirty)
  GIT_USER=$(git config user.name)

  # Set OS username if GIT_USER is empty
  [ -z "$GIT_USER" ] && GIT_USER=$USER

  if [[ -n "$EXIT_CODE" && "$EXIT_CODE" -eq 0 ]]; then
    echo -e "$MESSAGE | Success ✅"
    sentry-cli send-event --message "✅ $MESSAGE | $GIT_USER | Success " --tag version:"$GIT_VERSION" --user user:"$GIT_USER" --level info
  else
    echo -e "$MESSAGE | Failed ❌"
    sentry-cli send-event --message "❌ $MESSAGE | $GIT_USER | Failed " --tag version:"$GIT_VERSION" --user user:"$GIT_USER" --level error
  fi
}
