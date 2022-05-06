#!/usr/bin/env bash


PACKAGES=($(cat packages/brew.txt))
CASKS=($(cat packages/casks.txt))

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
    pretty_print "Installing Package(s)..."
    brew install ${PACKAGES[@]}
    pretty_print "Installing Cask(s)..."
    brew install --cask ${CASKS[@]} 
    install_visual_studio_code
    pretty_print "Installing Tool(s)..."
    install_sentry_cli
    install_sha2
}

function install_sha2(){
    pkg="sha2"
    if [ ! $(brew list $pkg --version) ];then 
        echo -e "${ORANGE} Installing $pkg"
        brew install $pkg
    else 
        echo -e "${ORANGE} $pkg Alreday Installed."
    fi 
}

function integrity(){
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
    else 
        echo -e "${ORANGE} .oh-my-zsh Alreday Installed." 
        # echo -e "$HOME/.oh-my-zsh Exists. Moving to $HOME/backup"
        # rm -fr $HOME/backup/.oh-my-zsh
        # mv $HOME/.oh-my-zsh $HOME/backup 
    fi 
    backup_copy_dotfile .zshrc 
    backup_copy_dotfile .zprofile 
    backup_copy_dotfile .alias.sh
    backup_copy_dotfile .aws_vault_env.sh
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
    echo "Dot Files Intgerity: $(integrity)" >> dotfiles/.setup
    brew_integrity=$(brew list --version $PACKAGE_LIST[@] | sha256sum | awk '{print $1}')
    echo "Installed Packages Integrity: $brew_integrity" >> dotfiles/.setup
    backup_copy_dotfile .setup
}

function check_integrity(){
    if cmp -s "${PWD}/dotfiles/.setup" "$HOME/.setup"; then
        echo -e "${GREEN}Integrity Check - Passsed${NC}\n"
		return 0
    else
        echo -e "${RED}Integrity Check - Failed${NC}\n"
		return 1
    fi
}

function setup(){
    exit_if_not_mac_os
    install_homebrew_if_not_installed
    upgrade_xcode
    brew_update_upgrade
    install_apps
    install_oh_my_zsh
    cleanup
    audit_trail
}

function setup_main(){
    echo "In Setup Main"
    start=$(date +%s)
    echo "Action: Setup | Start Time: $(date)" > dotfiles/.setup
    setup
    EXIT_CODE="$?"
    end=$(date +%s)
    runtime=$((end-start))
    MESSAGE="Mac Onboarding | $USER | Duration: $(_display_time $runtime) "
    log "$EXIT_CODE" "$MESSAGE"
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then 
    echo -e "Executing $0 "
    setup_main
fi

