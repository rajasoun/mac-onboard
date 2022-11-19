source ~/.alias.sh

###################################################################

## Measure & Improve
timezsh() {
  shell=${1-$SHELL}
  for i in $(seq 1 10); do /usr/bin/time $shell -i -c exit; done
}

## Time Plugins
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

## Check & source file
function source_file(){
  file=$1
  if [ -f "$file" ];then
      source $file
  else
      echo -e "Error sourcing $file. Check $HOME/.zprofile"
  fi
}
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

# source files
source_file "$HOME/.oh-my-zsh/oh-my-zsh.sh"
if [[ "$(uname -m)" == "arm64" ]]; then
  source_file "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source_file "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
else
  source_file "/usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  source_file "/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

# Visual Studio Code - CLI 
[[ "$TERM_PROGRAM" == "vscode" ]] && . "$(code --locate-shell-integration-path zsh)"