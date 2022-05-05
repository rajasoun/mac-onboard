#!/usr/bin/env bash

brew list | xargs brew uninstall --force
brew list --cask | xargs brew uninstall --force
rm -fr /usr/local/bin/sentry-cli
rm -fr $HOME/.oh-my-zsh