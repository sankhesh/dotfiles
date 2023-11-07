#!/usr/bin/env zsh

# Script to automatically configure whether to invoke a graphical UI or a command-line interface for
# password entry when signing git commits using GPG.
#
# To use ensure that git config uses this script like so:
#
#     git config --global gpg.program "~/.gpg2-display-aware.zsh
#
# Source: https://ertt.ca/blog/2022/01-10-git-gpg-ssh/

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
  if [[ -n "$DISPLAY" && -z "$SSH_CONNECTION" ]]; then
    exec gpg "$@"
  else
    exec gpg --pinentry-mode loopback "$@"
  fi
elif [[ "$OSTYPE" == "win32" ]]; then
  exec gpg.exe $@
fi
