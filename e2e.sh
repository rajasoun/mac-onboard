#!/usr/bin/env bash

# Fail on Error
set -euo pipefail
IFS=$'\n\t'

NC=$'\e[0m' # No Color
BOLD=$'\033[1m'
UNDERLINE=$'\033[4m'
RED=$'\e[31m'
GREEN=$'\e[32m'
BLUE=$'\e[34m'
ORANGE=$'\x1B[33m'


PACKAGES=($(cat packages/brew.txt))
CASKS=($(cat packages/casks.txt))

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

function pretty_print() {
  printf "\n%b\n" "$1"
}

function install_homebrew_if_not_installed(){
    # Check for Homebrew, install if not installed
    if test ! $(which brew); then
        pretty_print "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
}

function brew_update_upgrade(){
    brew update
    brew upgrade
}

function upgrade_xcode(){
    # find the CLI Tools update
    pretty_print "find CLI tools update"
    PROD=$(softwareupdate -l | grep "\*.*Command Line" | head -n 1 | awk -F"*" '{print $2}' | sed -e 's/^ *//' | tr -d '\n') || true
    # install it
    if [[ ! -z "$PROD" ]]; then
        softwareupdate -i "$PROD" --verbose
    fi
}

function install_brews(){
    #brew install ${PACKAGES[@]}
    for pkg in ${PACKAGES[@]};do 
        pkg=$(echo $pkg | xargs)
        if [ ! $(brew list $pkg --version) ];then 
            echo -e "${ORANGE} Installing $pkg"
            brew install $pkg
        else 
            echo -e "${ORANGE} $pkg Alreday Installed."
        fi 
    done
}

function install_brew_casks(){
    #brew install --cask ${CASKS[@]} 
    for pkg in  ${CASKS[@]} ;do 
        pkg=$(echo $pkg | xargs)
        if [ ! $(brew list --cask --version $pkg) ];then 
            echo -e "${ORANGE} Installing $pkg"
            brew install --cask $pkg
        else 
            echo -e "${ORANGE} $pkg Alreday Installed."
        fi 
    done
}

function install_visual_studio_code(){
    if [ ! -f "/usr/local/bin/code" ];then 
        echo -e "${ORANGE} Installing Visual Studio Code"
        brew install --cask visual-studio-code
    else 
        echo -e "${ORANGE} Visual Studio Code Alreday Installed."
    fi
}

function install_sentry_cli(){
    if [ ! -f "/usr/local/bin/sentry-cli" ];then 
        echo -e "${ORANGE} Installing Sentry CLI"
        curl -fsSL https://sentry.io/get-cli/ | bash
    else 
        echo -e "${ORANGE} Sentry CLI Alreday Installed."
    fi
}

function install_apps(){
    pretty_print "Installing packages..."
    install_brews
    pretty_print "Installing cask(s)..."
    install_brew_casks
    install_visual_studio_code
    install_sentry_cli
}

function integrity(){
    pkg="sha2"
    if [ ! $(brew list $pkg --version) ];then 
        echo -e "${ORANGE} Installing $pkg"
        brew install $pkg
    else 
        echo -e "${ORANGE} $pkg Alreday Installed."
    fi 
	sha256sum=$(find \
		"$HOME/.zshrc"  \
		"$HOME/.zprofile" \
		"$HOME/.alias.sh" \
		"$HOME/.aws_vault_env" \
		-type f -print0 \
	| sort -z | xargs -r0 sha256sum | sha256sum | awk '{print $1}')
	echo $sha256sum
}

function backup_copy_dotfile(){
    FILE=$1
    if [ -f $HOME/$FILE ];then 
        # move to backup directory
        echo -e "${ORANGE} $FILE exists - Moving to $HOME/backup"
        mv $HOME/$FILE $HOME/backup
    fi 
    cp -i dotfiles/$FILE $HOME \
        && echo -e "${GREEN} dotfiles/$FILE copied to $HOME/$FILE ${NC}" \
        || echo -e "${RED} dotfiles/$FILE Does Not Exists ${NC}"
}

function install_oh_my_zsh(){
    mkdir -p $HOME/backup
    if [ ! -d "$HOME/.oh-my-zsh" ]; then 
        curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash
        PLUGIN_FOLDER="$HOME/.oh-my-zsh/custom/plugins"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_FOLDER"/zsh-syntax-highlighting
        git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_FOLDER"/zsh-autosuggestions
        backup_copy_dotfile .zshrc 
        backup_copy_dotfile .zprofile 
        backup_copy_dotfile .alias.sh
        backup_copy_dotfile .aws_vault_env.sh
    else 
        echo -e "${ORANGE} .oh-my-zsh Alreday Installed." 
        # echo -e "$HOME/.oh-my-zsh Exists. Moving to $HOME/backup"
        # rm -fr $HOME/backup/.oh-my-zsh
        # mv $HOME/.oh-my-zsh $HOME/backup 
    fi 
}

function exit_if_not_mac_os(){
    case "$(uname -s)" in
    Darwin) echo -e "${GREEN}OS: Mac OS | User: $USER | Machine: $(hostname)${NC}";;
    *)  echo -e "${RED}Non Mac OS${NC}" && exit 1;;
    esac
}

function cleanup(){
    echo "Cleaning up"
    brew cleanup
}

function audit_trail(){
    echo "$(integrity)" >> dotfiles/.setup
    backup_copy_dotfile .setup
}

function main(){
    # echo "$(date)" > dotfiles/.setup
    # exit_if_not_mac_os
    # install_homebrew_if_not_installed
    # brew_update_upgrade
    # install_apps
    install_oh_my_zsh
    # cleanup
    # audit_trail
    echo -e "MacOS Setup Done"
}

main

