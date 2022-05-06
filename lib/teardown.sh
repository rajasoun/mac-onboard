#!/usr/bin/env bash

function teardown(){
    exit_if_not_mac_os
    install_homebrew_if_not_installed
    upgrade_xcode
    brew_update_upgrade
    install_apps
    install_oh_my_zsh
    cleanup
    audit_trail
}

function teardown_main(){
    start=$(date +%s)
    echo "$start" > dotfiles/.setup
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
