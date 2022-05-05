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


PACKAGES=(
    ca-certificates
    zsh
    zsh-autosuggestions 
    zsh-syntax-highlighting 
    aws-vault
    coreutils
    netcat
    httpie
    jq
    wget
    curl
    gh
)

CASKS=(
    visual-studio-code
    iterm2
)


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

function install_apps(){
    pretty_print "Installing packages..."
    #brew install ${PACKAGES[@]}
    for pkg in ${PACKAGES[@]};do 
        if [ ! $(brew list $pkg --version) ];then 
            echo -e "${ORANGE} Installing $pkg"
            brew install $pkg
        else 
            echo -e "${ORANGE} $pkg Alreday Installed."
        fi 
    done
    pretty_print "Installing cask(s)..."
    #brew install --cask ${CASKS[@]} 
    for pkg in  ${CASKS[@]} ;do 
        if [ ! $(--version) ];then 
            echo -e "${ORANGE} Installing $pkg"
            brew install --cask $pkg
        else 
            echo -e "${ORANGE} $pkg Alreday Installed."
        fi 
    done
    brew list --casks --version
    pretty_print "Installing Sentry CLI..."
    curl -fsSL https://sentry.io/get-cli/ | bash
}

function cleanup(){
    echo "Cleaning up"
    brew cleanup
    echo "Ask the doctor"
    brew doctor
}

function install_oh_my_zsh(){
    sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"
    PLUGIN_FOLDER="/home/$USER/.oh-my-zsh/custom/plugins"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGIN_FOLDER"/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions "$PLUGIN_FOLDER"/zsh-autosuggestions
    cp dotfiles/.zshrc          $HOME
    cp dotfiles/.zprofile       $HOME
    cp dotfiles/.alias.sh       $HOME
    cp dotfiles/aws_vault_env   $HOME
}

function exit_if_not_mac_os(){
    case "$(uname -s)" in
    Darwin) echo -e "${GREEN}OS: Mac OS | User: $USER | Machine: $(hostname)${NC}";;
    *)  echo -e "${RED}Non Mac OS${NC}" && exit 1;;
    esac
}

function main(){
    exit_if_not_mac_os
    install_homebrew_if_not_installed
    brew_update_upgrade
    install_apps
    install_oh_my_zsh
    cleanup
    echo -e "MacOS Setup Done"
}

main

