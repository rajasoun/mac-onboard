#!/usr/bin/env bash

FAILED=()

if [ -z "$HOME" ]; then
    HOME="/root"
fi

function echoStderr(){
    echo "$@" 1>&2
}

function check() {
    LABEL=$1
    shift
    echo -e "\n🧪 Testing $LABEL"
    if "$@"; then
        echo -e "✅  Passed!"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

function reportResults() {
    failed_results="${#FAILED[@]}"
    if [ "${failed_results}" -ne 0 ]; then
        echoStderr -e "\n💥  Failed tests:" "${FAILED[@]}"
        EXIT_CODE="1"
        if [ ! -z $SENTRY_DSN ];then
            log_sentry "$EXIT_CODE" "mac-onboard | e2e_tests.sh"
        fi
        exit $EXIT_CODE
    else
        echo -e "\n💯  All passed!"
        EXIT_CODE="0"
        if [ ! -z $SENTRY_DSN ];then
            log_sentry "$EXIT_CODE" "mac-onboard | e2e_tests.sh"
        fi
        exit $EXIT_CODE
    fi
}

function checkOSPackages() {
    PACKAGE_LIST=($(cat packages/brew.txt))
    LABEL=$1
    echo -e "\n🧪 Testing $LABEL"
    brew list --version $PACKAGE_LIST[@]
    if [  $?  ];then
        echo -e "✅ $LABEL check passed.\n"
        return 0
    else
        echoStderr "❌ $LABEL check failed.\n"
        FAILED+=("$LABEL")
        return 1
    fi
}

function check_vs_extensions(){
    extensions=$(code --list-extensions)
    pkg_extensions=$(cat packages/extensions.txt)
    diff=$(diff <(echo $extensions) <(echo $pkg_extensions))
    if [[ -z $diff ]]; then
        echo "✅  Visual Studio Code Extension : $pkg Passed!"
        return 0
    else
        echoStderr "❌ Visual Studio Code Extension : $pkg check failed.\n"
        FAILED+=("$LABEL")
        return 1
    fi
}

function check_pkg_installed(){
    while IFS="," read -r pkg command
    do
        check "$pkg" ${command[@]}
    done < <(tail -n +2 packages/tests.csv)
}

function e2e_test(){
    check "brew" brew --version && checkOSPackages "common-os-packages"

    # Test Visual Studio Extension only in Local Laptop ot in Github Action
    # Reason: The provision to install code is available witin teh editor an dnot outside
    if [ -z $CI ]; then 
        check_vs_extensions 
    fi

    # checks with result with first line
    check "oh-my-zsh" [ -d "$HOME/.oh-my-zsh" ]
    check_pkg_installed
    
    #check "pre-commit" pre-commit run --all-files
    # Report result
    reportResults
}

function e2e_tests_main(){
    start=$(date +%s)
    #echo "Action: Test | Start Time: $(date)" >> dotfiles/.setup
    e2e_test
    EXIT_CODE="$?"
    end=$(date +%s)
    runtime=$((end-start))
    MESSAGE="Mac Onboarding e2e Test | $USER | Duration: $(_display_time $runtime) "
    log "$EXIT_CODE" "$MESSAGE"
}

# Ignore main when sourced
[[ $0 != "$BASH_SOURCE" ]] && sourced=1 || sourced=0
if [ $sourced = 0 ];then
    echo -e "Executing $0 "
    e2e_tests_main
fi
