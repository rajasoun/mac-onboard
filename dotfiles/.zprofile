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
export PATH="/usr/local/opt/openssl@1.1/bin:$PATH"
export DYLD_LIBRARY_PATH="/usr/local/Cellar/openssl@1.1/1.1.1g/lib:$DYLD_LIBRARY_PATH"
export LDFLAGS="-L/usr/local/opt/openssl@1.1/lib"
export CPPFLAGS="-I/usr/local/opt/openssl@1.1/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl@1.1/lib/pkgconfig"

# CURL
export LDFLAGS="-L/usr/local/opt/curl/lib"
export CPPFLAGS="-I/usr/local/opt/curl/include"

################################################################################################
# Core Utils
export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

#curl 
export PATH="/usr/local/opt/curl/bin:$PATH"

# zsh
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/usr/local/share/zsh-syntax-highlighting/highlighters
################################################################################################
 
