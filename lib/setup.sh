#!/usr/bin/env bash

PACKAGES=($(cat $BASEDIR/packages/brew.txt))
CASKS=($(cat $BASEDIR/packages/casks.txt))

function fix_brew_path(){
  if [[ "$(uname -m)" == "arm64" ]]; then
    homebrew_prefix_default=/opt/homebrew
  else
    homebrew_prefix_default=/usr/local
  fi
  export PATH="$homebrew_prefix_default/bin:$PATH"  
}

function install_homebrew_if_not_installed(){
    # Check for Homebrew, install if not installed
    if test ! $(which brew); then
        pretty_print "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
    fi
    fix_brew_path
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
        EXTENSIONS=$(sed -e '/^ *$/d' $BASEDIR/packages/extensions.txt)
        echo $EXTENSIONS | xargs -L 1 code --install-extension
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
    install_pkg "sha2"
}

function install_pkg(){
    pkg=${1:-sha2}
    if brew list --versions  $pkg > /dev/null; then
        echo -e "${ORANGE} $pkg Alreday Installed."
    else
        echo -e "${ORANGE} Installing $pkg"
        brew install $pkg
    fi
    eval "$(/opt/homebrew/bin/brew shellenv)"
}

function integrity(){
	sha256sum=$(find \
		"$HOME/.zshrc"  \
		"$HOME/.zprofile" \
		"$HOME/.alias.sh" \
		"$HOME/.aws_vault_env.sh" \
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

function install_global_node_packages(){
    NODE_PACKAGES=($(cat $BASEDIR/packages/node_packages.txt))
    npm install -g ${NODE_PACKAGES[@]}
}

function upgrade_pip(){
    python3.10 -m pip install --upgrade pip
}

function install_global_python_packages(){
    pip3 --disable-pip-version-check \
            --no-cache-dir install --force-reinstall \
            -r $BASEDIR/packages/requirements.txt
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
    echo "Dot Files Intgerity: $(integrity)" > "$BASEDIR/dotfiles/.setup"
    brew_integrity=$(brew list --version | sha256sum | awk '{print $1}')
    echo "Installed Packages (via brew) Integrity: $brew_integrity" >> "$BASEDIR/dotfiles/.setup"
    pip_integrity=$(pip3 list --version | sha256sum | awk '{print $1}')
    echo "Installed Packages (via pip3) Integrity: $pip_integrity" >> "$BASEDIR/dotfiles/.setup"
    npm_integrity=$(npm list --global --json | sha256sum | awk '{print $1}')
    echo "Installed Packages (via npm) Integrity: $npm_integrity" >> "$BASEDIR/dotfiles/.setup"
}

function update_audit_trail(){
    echo "Action: Setup | Start Time: $(date)" > "$BASEDIR/dotfiles/.setup"
    audit_trail
    backup_copy_dotfile .setup
}

function check_brew_drift(){
    brew_integrity=$(brew list --version | sha256sum | awk '{print $1}')
    if [ $(cat "${HOME}/.setup" | grep -c $brew_integrity) = 1 ];then
        echo -e "${GREEN}\nDrift Check - Passsed${NC}"
        echo -e "   ${GREEN}No Installation(s) found outside of Automation using Homebrew${NC}\n"
        return 0
    else
        echo -e "${RED}\nDrfit Check - Failed${NC}\n"
        echo -e "   ${ORGANGE}Installation(s) found outside of Automation using Homebrew${NC}\n"
        return 1
    fi
}

function check_pip_drift(){
    pip_integrity=$(pip list --version | sha256sum | awk '{print $1}')
    if [ $(cat "${HOME}/.setup" | grep -c $pip_integrity) = 1 ];then
        echo -e "${GREEN}\nDrift Check - Passsed${NC}"
        echo -e "   ${GREEN}No Installation(s) found outside of Automation using pip3${NC}\n"
        return 0
    else
        echo -e "${RED}\nDrfit Check - Failed${NC}\n"
        echo -e "   ${ORGANGE}Installation(s) found outside of Automation using pip3${NC}\n"
        return 1
    fi
}

function check_npm_drift(){
    npm_integrity=$(npm list --global --json | sha256sum | awk '{print $1}')
    if [ $(cat "${HOME}/.setup" | grep -c $npm_integrity) = 1 ];then
        echo -e "${GREEN}\nDrift Check - Passsed${NC}"
        echo -e "   ${GREEN}No Installation(s) found outside of Automation using npm${NC}\n"
        return 0
    else
        echo -e "${RED}\nDrfit Check - Failed${NC}\n"
        echo -e "   ${ORGANGE}Installation(s) found outside of Automation using npm${NC}\n"
        return 1
    fi
}

function check_drift(){
    check_brew_drift
    check_pip_drift
    check_npm_drift
}

function setup(){
    exit_if_not_mac_os
    install_homebrew_if_not_installed
    upgrade_xcode
    brew_update_upgrade
    install_apps
    install_oh_my_zsh
    install_global_node_packages
    install_global_python_packages
    cleanup
    update_audit_trail
}

function setup_main(){
    echo "In Setup Main"
    start=$(date +%s)
    echo "Action: Setup | Start Time: $(date)" > $"$BASEDIR/dotfiles/.setup"
    setup
    EXIT_CODE="$?"
    end=$(date +%s)
    runtime=$((end-start))
    MESSAGE="Mac Onboarding | $USER | Duration: $(_display_time $runtime) "
    log "$EXIT_CODE" "$MESSAGE"
    #echo -e "${BOLD}\nSpeed Test\n${NC}"
    #docker run --rm rajasoun/speedtest:0.1.0 "/go/bin/speedtest-go"
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then
    echo -e "Executing $0 "
    setup_main
fi
