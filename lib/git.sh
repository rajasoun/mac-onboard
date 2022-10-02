#!/usr/bin/env bash

export $(grep -v '^#' env.ini | xargs)

function git-config() {
  echo -e "${GREEN}${UNDERLINE}Git Configuration${NC}\n"
  MSG="${ORANGE}  Full Name ${NC}${ORANGE} : ${NC}"
  printf "$MSG"
  read -r "USER_NAME"
  MSG="${ORANGE}  EMail ${NC}${ORANGE} : ${NC}"
  printf "$MSG"
  read -r "EMAIL"
  git config user.name   "$USER_NAME"
  git config user.emanil "$EMAIL"
  echo -e "\nGit Config $USER_NAME Done !!!"
}

function git_config_main(){
    git-config
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then
    echo -e "Executing $0 \n"
    git_config_main
fi
