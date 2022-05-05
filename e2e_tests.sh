#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FAILED=()

if [ -z "$HOME" ]; then
    HOME="/root"
fi

function echoStderr(){
    echo "$@" 1>&2
}

function log_sentry() {
  EXIT_CODE="$1"
  MESSAGE="$2"
  GIT_VERSION=$(git describe --tags --always --dirty)
  GIT_USER=$(git config user.name)

  # Set OS username if GIT_USER is empty
  [ -z "$GIT_USER" ] && GIT_USER=$USER

  if [[ -n "$EXIT_CODE" && "$EXIT_CODE" -eq 0 ]]; then
    echo -e "$MESSAGE | Success ✅"
    sentry-cli send-event --message "✅ $MESSAGE | $GIT_USER | Success " --tag version:"$GIT_VERSION" --user user:"$GIT_USER" --level info
  else
    echo -e "$MESSAGE | Failed ❌"
    sentry-cli send-event --message "❌ $MESSAGE | $GIT_USER | Failed " --tag version:"$GIT_VERSION" --user user:"$GIT_USER" --level error
  fi
}

function echoStderr(){
    echo "$@" 1>&2
}

function check() {
    LABEL=$1
    shift
    echo -e "\n🧪 Testing $LABEL"
    if "$@"; then
        echo "✅  Passed!"
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
    PACKAGES_COUNT=$(grep '\S' packages/brew.txt  | wc -l)
    LABEL=$1
    echo -e "\n🧪 Testing $LABEL"
    INSTALLED_COUNT=$(brew list --version $PACKAGE_LIST[@] | wc -l )
    echo "PACKAGES_COUNT: $PACKAGES_COUNT | INSTALLED_COUNT: $INSTALLED_COUNT"
    if [  "$PACKAGES_COUNT" = "$PACKAGES_COUNT"  ];then
        echo -e "✅ checkOSPackages - SUCESS"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

checkOSPackages "common-os-packages" 

check "sudo" sudo --version
check "zsh" zsh --version
check "oh-my-zsh" [ -d "$HOME/.oh-my-zsh" ]
check "curl" curl --version
check "wget" wget --version

check "gh" gh --version
check "http" http --version
check "jq" jq --version
check "netcat" netcat --version

check "aws-vault" aws-vault --version
check "code" code --version
check "sentry-cli" sentry-cli --version

#check "pre-commit" pre-commit run --all-files
# Report result
reportResults

