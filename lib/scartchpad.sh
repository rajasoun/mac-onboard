#!/usr/bin/env bash 

function setup_main(){
    echo "In setup_main"
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then 
    echo -e "Executing $0 "
    setup_main
fi
