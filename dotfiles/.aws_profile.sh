#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'

function aws_profile() {
  if [ ! -f ~/.aws/config ]; then
    echo -e "You must have ~/.aws/config \n"
    return 1
  fi

  local list=$(grep '^[[]profile' <~/.aws/config | awk '{print $2}' | sed 's/]$//')
  if [[ -z $list ]]; then
    echo -e "You must have ~/.aws/config"
    return 1
  fi
  # if AWS_PROFILE is empty - Interative Mode
  if [ -z "$AWS_PROFILE" ];then
    local nlist=$(echo "$list" | nl)
    while [[ -z $AWS_PROFILE ]]; do
        local AWS_PROFILE=$(read -p "AWS profile? `echo $'\n\r'`$nlist `echo $'\n> '`" N; echo "$list" | sed -n ${N}p)
    done
  fi
 
  AWS_VAULT=
  CMD="$@"
  if [ -z "$CMD" ];then
    echo -e "\n${BOLD}AWS Profile: $AWS_PROFILE.${NC}\n"
  fi
}
aws_profile "$@"
