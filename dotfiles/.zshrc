source ~/.alias.sh

###################################################################
# Either Prezto or oh-my-zsh can be used

# Prezto — Instantly Awesome Zsh
# setopt EXTENDED_GLOB
# unsetopt correct
# unsetopt correctall
# DISABLE_CORRECTION="true"

# source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"

## oh-my-zsh 
export ZSH="$HOME/.oh-my-zsh"
export ZSH_THEME="robbyrussell"


plugins=(
  git 
  zsh-syntax-highlighting 
  zsh-autosuggestions 
)
source $ZSH/oh-my-zsh.sh
alias ohmyzsh="code ~/.oh-my-zsh"
###################################################################

## Measure & Improve

timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

timeplugins() {
  # Load all of the plugins that were defined in ~/.zshrc  
  for plugin ($plugins); do
    timer=$(($(gdate +%s%N)/1000000))
    if [ -f $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh ]; then  
      source $ZSH_CUSTOM/plugins/$plugin/$plugin.plugin.zsh  
    elif [ -f $ZSH/plugins/$plugin/$plugin.plugin.zsh ]; then  
      source $ZSH/plugins/$plugin/$plugin.plugin.zsh  
    fi  
    now=$(($(gdate +%s%N)/1000000))
    elapsed=$(($now-$timer))  
    echo $elapsed":" $plugin  
  done 
}

