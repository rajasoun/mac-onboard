#!/usr/bin/env sh

# Edit ohmyzsh
alias ohmyzsh="code ~/.oh-my-zsh"

# AWS Vault zsh shell
alias aws-env='$HOME/.aws_vault_env.sh'

# Mac Alias
alias clean-mac='find . -name '.DS_Store' -type f -delete'

# zsh config
alias zshconfig='code ~/.zshrc ~/.zprofile ~/.alias.sh'

# Docker Clean All
alias dclean_all='curl -fsSL https://git.io/Jn13Q | sh'

# SSH Keygen
alias ssh_keygen='ssh-keygen -q -t rsa -N '' -f "$HOME/.ssh/id_rsa" -C "$USERNAME@cisco.com" <<<y 2>&1 >/dev/null'

# Git Rename master to main
alias git_m2m='git branch -M main && git push -u origin main'

# Find port
lsof_port() {
    # exits if command-line parameter absent
    : "${1?"Usage: lsof_port <port_number>"}"
    lsof -nP -iTCP -sTCP:LISTEN | grep "$1"
}

# Quick Utility to view Dockerfile from image
docker_image_history(){
    : "${1?"Usage: docker_image_history <docker_image_id>"}"
    docker history --no-trunc "$1" \
         | tac | tr -s ' ' | cut -d " " -f 5- | \
         sed 's,^/bin/sh -c #(nop) ,,g' | \
         sed 's,^/bin/sh -c,RUN,g' | \
         sed 's, && ,\n  & ,g' | \
         sed 's,\s*[0-9]*[\.]*[0-9]*\s*[kMG]*B\s*$,,g'
}

# Remove no non-running containers
dclean(){
    # Exit if there are no non-running containers
    if [[ $(docker ps --filter "status=exited" | wc -l) -eq '1' ]]; then
        echo "Nothing to Clean. Zero non-running containers !!!"
        return 0 2> /dev/null || exit 0
    fi
    echo "Removing all non-running containers"
    docker ps --filter "status=exited"
    # docker ps --filter "status=exited" | awk '{print $1}' | tail -n +2 | xargs  docker rm
    docker container prune
}

# Cleanup unnecessary files and optimize the local repository
gclean(){
    git gc --aggressive --prune=all
}
