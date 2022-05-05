#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FAILED=()

if [ -z "$HOME" ]; then
    HOME="/root"
fi

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

function checkMultiple() {
    PASSED=0
    LABEL="$1"
    echo -e "\n🧪 Testing $LABEL."
    shift; MINIMUMPASSED=$1
    shift; EXPRESSION="$1"
    while [ "$EXPRESSION" != "" ]; do
        if $EXPRESSION; then ((PASSED++)); fi
        shift; EXPRESSION=$1
    done
    if [ "$PASSED" -ge "$MINIMUMPASSED" ]; then
        echo "✅ Passed!"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

function checkOSPackages() {
    LABEL=$1
    shift
    echo -e "\n🧪 Testing $LABEL"
    if brew list --versions go  "$@"; then
        echo "✅  Passed!"
        return 0
    else
        echoStderr "❌ $LABEL check failed."
        FAILED+=("$LABEL")
        return 1
    fi
}

function checkExtension() {
    # Happens asynchronusly, so keep retrying 10 times with an increasing delay
    EXTN_ID="$1"
    TIMEOUT_SECONDS="${2:-10}"
    RETRY_COUNT=0
    echo -e -n "\n🧪 Looking for extension $1 for maximum of ${TIMEOUT_SECONDS}s"
    until [ "${RETRY_COUNT}" -eq "${TIMEOUT_SECONDS}" ] || \
        [ ! -e "$HOME/.vscode-server/extensions/${EXTN_ID}*" ] || \
        [ ! -e "$HOME/.vscode-server-insiders/extensions/${EXTN_ID}*" ] || \
        [ ! -e "$HOME/.vscode-test-server/extensions/${EXTN_ID}*" ] || \
        [ ! -e "$HOME/.vscode-remote/extensions/${EXTN_ID}*" ]
    do
        sleep 1s
        (( RETRY_COUNT++ ))
        echo -n "."
    done

    if [ "${RETRY_COUNT}" -lt "${TIMEOUT_SECONDS}" ]; then
        echo -e "\n✅ Passed!"
        return 0
    else
        echoStderr -e "\n❌ Extension $EXTN_ID not found."
        FAILED+=("$LABEL")
        return 1
    fi
}

function checkCommon(){
    PACKAGE_LIST="ca-certificates   \
    ca-certificates                 \
    zsh                             \
    zsh-autosuggestions             \ 
    zsh-syntax-highlighting         \ 
    aws-vault                       \
    coreutils                       \
    netcat                          \
    httpie                          \
    jq                              \
    wget                            \
    curl                            \
    gh"

    # shellcheck disable=SC2086
    checkOSPackages "common-os-packages" ${PACKAGE_LIST}
    #checkMultiple "vscode-server" 1 "[ -d $HOME/.vscode-server/bin ]" "[ -d $HOME/.vscode-server-insiders/bin ]" "[ -d $HOME/.vscode-test-server/bin ]" "[ -d $HOME/.vscode-remote/bin ]" "[ -d $HOME/.vscode-remote/bin ]"
    #check "locale" [ "$(locale -a | grep en_US.utf8)" ]
    check "sudo" sudo --version
    check "zsh" zsh --version
    check "oh-my-zsh" [ -d "$HOME/.oh-my-zsh" ]
    check "code" code --version
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

# Run common tests
checkCommon

# Definition specific tests
#checkExtension "ms-azuretools.vscode-docker"
check "gh" gh --version
check "sentry-cli" sentry-cli --version
check "http" http --version

#check "pre-commit" pre-commit run --all-files
# Report result
reportResults

