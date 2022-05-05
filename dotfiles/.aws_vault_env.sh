#!/usr/bin/env bash

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'

function add_profile_to_aws_vault(){
    while true
    do
        read -r -p 'Add Profile to aws-vault (y/n)? ' choice
        case "$choice" in
        n|N) break;;
        y|Y)
            read -r -p 'AWS Profile Name : ' profile
            aws-vault add $profile;;
        *) echo 'Response not valid';;
        esac
    done
}

function aws_vault_exec() {
  if ! which aws-vault >/dev/null; then
    echo -e "You must have 'aws-vault' installed.\nSee https://github.com/99designs/aws-vault/\n"
    return 1
  fi

  if [ ! -f ~/.aws/config ]; then
    echo -e "You must have AWS profiles set up to use this.\nSee https://github.com/99designs/aws-vault/\n"
    add_profile_to_aws_vault
    return 1
  fi

  local list=$(grep '^[[]profile' <~/.aws/config | awk '{print $2}' | sed 's/]$//')
  if [[ -z $list ]]; then
    echo -e "You must have AWS profiles set up to use this.\nSee https://github.com/99designs/aws-vault/"
    add_profile_to_aws_vault
    return 1
  fi
  # if AWS_PROFILE is empty - Interative Mode
  if [ -z "$AWS_PROFILE" ];then
    local nlist=$(echo "$list" | nl)
    while [[ -z $AWS_PROFILE ]]; do
        local AWS_PROFILE=$(read -p "AWS profile? `echo $'\n\r'`$nlist `echo $'\n> '`" N; echo "$list" | sed -n ${N}p)
    done
  fi
  # if aws-vault credentials are present for AWS_PROFILE
  if [ ! $(aws-vault list | awk '{print $2}' | grep -c "$AWS_PROFILE" >/dev/null 2>&1) ];then
    echo -e "\n✅ AWS Profile $AWS_PROFILE"
  else
    echo -e "\n💣 Missing Credentials For $AWS_PROFILE \n"
    aws-vault add $AWS_PROFILE
    echo -e "\n✅ AWS Credentials added for Profile $AWS_PROFILE"
  fi
  # aws-vault list | awk '{print $2}' | grep -c "$AWS_PROFILE" >/dev/null 2>&1 && \
  #   (echo -e "\n✅ AWS Profile $AWS_PROFILE") || \
  #   (echo -e "\n💣 Missing Credentials For $AWS_PROFILE \n";aws-vault add $AWS_PROFILE)
  AWS_VAULT=
  CMD="$@"
  if [ -z "$CMD" ];then
    echo -e "\n${BOLD}AWS Profile: $AWS_PROFILE. ${UNDERLINE}CTRL-D to exit.${NC}\n"
    #export IGNORE_GHELP=1
    echo -e "${BOLD}Switching to Base Directory${NC}"
    echo -e "You were in : ${PWD}"
    cd "$(git rev-parse --show-toplevel)"
    aws-vault exec $AWS_PROFILE --no-session -- zsh
  else
    echo -e "\n${BOLD}${GREEN}Executing $CMD ${NC}\n"
    aws-vault exec $AWS_PROFILE --no-session -- $CMD
  fi
}
aws_vault_exec "$@"
