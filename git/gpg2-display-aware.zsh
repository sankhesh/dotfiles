#!/usr/bin/env zsh

# Script to automatically configure whether to invoke a graphical UI or a command-line interface for
# password entry when signing git commits using GPG.
#
# To use ensure that git config uses this script like so:
#
#     git config --global gpg.program "~/.gpg2-display-aware.zsh
#
# Source: https://ertt.ca/blog/2022/01-10-git-gpg-ssh/

# By default, invoke gpg
GPG_EXE=gpg
if grep -qi microsoft /proc/version || "$OSTYPE" == "win32"; then
  # For WSL, use gpg.exe
  GPG_EXE=gpg.exe
  # Set a display variable
  DISPLAY=1
fi

# For WSL to test SSH_CONNECTION, set the environment variable WSLENV
# i.e. WSLENV=SSH_CONNECTION
if [[ -n "$DISPLAY" && -z "$SSH_CONNECTION" ]]; then
  exec $GPG_EXE "$@"
else
  exec $GPG_EXE --pinentry-mode loopback "$@"
fi
