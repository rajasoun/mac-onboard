#!/usr/bin/env bash

function teardown(){
    brew list | xargs brew uninstall --force
    brew list --cask | xargs brew uninstall --force
    rm -fr /usr/local/bin/sentry-cli
    rm -fr $HOME/.oh-my-zsh
    rm -fr  /usr/local/share/zsh-autosuggestions
    rm -fr  /usr/local/share/zsh-syntax-highlighting
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)"
}

function teardown_main(){
    start=$(date +%s)
    echo "Action: Teardown | Start Time: $(date)" > dotfiles/.setup
    teardown
    EXIT_CODE="$?"
    end=$(date +%s)
    runtime=$((end-start))
    MESSAGE="Mac Onboarding - Teardown | $USER | Duration: $(_display_time $runtime) "
    log "$EXIT_CODE" "$MESSAGE"
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then 
    echo -e "Executing $0 "
    teardown_main
fi
