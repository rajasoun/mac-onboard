# shell profiling - time
zmodload zsh/zprof

autoload -Uz compinit
if [ $(date +'%j') != $(/usr/bin/stat -f '%Sm' -t '%j' ${ZDOTDIR:-$HOME}/.zcompdump) ]; then
    compinit
else
    compinit -C
fi

## You language environment
export LANG=en_US.UTF-8

# aws-vault
export AWS_VAULT_BACKEND=file

# OpenSSL
export LDFLAGS="-L/usr/local/opt/openssl@3/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@3/include"

# CURL
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"

# python@3.10
export LDFLAGS="-L/usr/local/opt/python@3.10/lib"

################################################################################################
#openssl@3
export PATH="/usr/local/opt/openssl@3/bin:$PATH"

# curl
export PATH="/usr/local/opt/curl/bin:$PATH"

# python@3.10
export PATH="/usr/local/opt/python@3.10/bin:$HOME/Library/Python/3.10/bin:$PATH"

# brew 
if [[ "$(uname -m)" == "arm64" ]]; then
    homebrew_prefix_default=/opt/homebrew
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters 
else
    homebrew_prefix_default=/usr/local
    export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
fi
export PATH="$homebrew_prefix_default/bin:$PATH" 

# Core Utils
export PATH="$($(which brew) --prefix coreutils)/libexec/gnubin:$PATH"
################################################################################################
