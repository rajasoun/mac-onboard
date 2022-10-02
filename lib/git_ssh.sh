#!/usr/bin/env bash

GIT="github.com"

# Returns true (0) if this the given command/app is installed and on the PATH or false (1) otherwise.
function _is_command_found {
  local -r name="$1"
  command -v "$name" >/dev/null ||
    raise_error "${RED}$name is not installed. Exiting...${NC}"
}

# Copy Content to Clipboard
function _copy_to_clipboard() {
  CONTENT=$1
  MSG=""
  case "$OSTYPE" in
  *msys* | *cygwin*)
    os="$(uname -o)"
    if [[ "$os" == "Msys" ]] || [[ "$os" == "Cygwin" ]]; then
      clip <"$CONTENT"
    fi
    ;;
  *darwin* | *Darwin*)
    os="$(uname -s)"
    pbcopy <"$CONTENT"
    ;;
  *)
    os="$(uname -s)"
    echo ""
    cat "$CONTENT"
    echo ""
    ;;
  esac
  echo -e "\n${GREEN}$MSG${NC}\n"
}

# Print SSH Public Key
function _print_details() {
  echo -e "Add SSH Public Key to GitHub"
  echo -e "${BOLD}GoTo${NC}: ${ORANGE}https://$GIT/settings/ssh/new\n${NC}"
}

# Check Connection
function _check_connection() {
  server=$1
  port=$2
  if nc -z "$server" "$port" 2>/dev/null; then
    echo -e "${GREEN}Internet Connection $server  ✓${NC}\n"
    return 0
  else
    echo -e "${RED}Internet Connection $server  ✗${NC}\n"
    return 1
  fi
}

# Prompt to User for Continue or Exit
function _prompt_confirm() {
  # call with a prompt string or use a default
  local response msg="${1:-${ORANGE}Do you want to continue${NC}} (y/[n])? "
  if test -n "$ZSH_VERSION"; then
    read -q "response?$msg"
  elif test -n "$BASH_VERSION"; then
    shift
    read -r "$@" -p "$msg" response || echo
  fi

  case "$response" in
  [yY][eE][sS] | [yY])
    return 0
    ;;
  [nN][no][No] | [nN])
    echo -e "${BOLD}${RED}Exiting setup${NC}\n"
    exit 1
    ;;
  *)
    return 1
    ;;
  esac
}

function generate-ssh-keys() {
  KEYS_PATH="${PWD}/config/keys"
  PRIVATE_KEY="$KEYS_PATH/id_rsa"
  PUBLIC_KEY="${PRIVATE_KEY}.pub"

  if [ ! -f $PUBLIC_KEY  ];then
    echo -e "${GREEN}${UNDERLINE}\nGenerating SSH Keys for $USER_NAME${NC}\n"
    _is_command_found ssh-keygen
    echo -e "Generating SSH Keys for $USER_NAME"
    ssh-keygen -q -t rsa -N '' -f "$PRIVATE_KEY" -C "$EMAIL" <<<y 2>&1 >/dev/null

    echo "Set File Permissions"
    # Fix Permission For Private Key
    chmod 400 "$PUBLIC_KEY"
    chmod 400 "$PRIVATE_KEY"
    echo -e "SSH Keys Generated Successfully" 
    _copy_to_clipboard "$PUBLIC_KEY"
    _print_details
    _prompt_confirm "Is SSH Public Added to GitHub"
    _check_connection "$GIT" 443
    ssh -T git@$GIT
  else
    echo -e "${ORANGE}SSH Keys Exist\n${NC}"
  fi
}

# Git SSH Fix - If devcontainer Terminal starts before initialization
function git-ssh-fix() {
  ERROR_MSG="${RED}Private SSH Key Not Present. DONT PANIC.${NC}"
  NEXT_STEP="${ORANGE}Run -> ssh-config${NC} Exiting..."
  MSG="$ERROR_MSG \n $NEXT_STEP"
  [[ ! -f "$PRIVATE_KEY" ]] && echo -e "$MSG" && return 1

  ssh-add -l > /dev/null
  EXIT_CODE=$?
  if [  "$EXIT_CODE" = 1  ];then
      echo -e "${ORANGE}SSH Identities Not Present${NC}"
      echo -e "Starting Fresh ssh-agen & Adding $PRIVATE_KEY to ssh-add"
      echo -e "Running -> eval $(ssh-agent -s) && ssh-add $PRIVATE_KEY"
      eval "$(ssh-agent -s)" && ssh-add $PRIVATE_KEY
  else
      echo -e "${GREEN}SSH Identiies Present. Fix Not Required${NC}"
      echo -e "${ORANGE}Run -> gstatus${NC}"
      ssh-add -l
  fi
}

function git_ssh_config_main(){
    generate-ssh-keys
    git-ssh-fix
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then
    echo -e "Executing $0 \n"
    git_ssh_config_main
fi
