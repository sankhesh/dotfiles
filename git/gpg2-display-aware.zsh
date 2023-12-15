#!/usr/bin/env zsh

# Script to automatically configure whether to invoke a graphical UI or a command-line interface for
# password entry when signing git commits using GPG.
#
# To use ensure that git config uses this script like so:
#
#     git config --global gpg.program "~/.gpg2-display-aware.zsh
#
# Source: https://ertt.ca/blog/2022/01-10-git-gpg-ssh/

# To test gpg
#
# ```
# echo "hello" | ~/.git/gpg2-display-aware.zsh --clearsign
# ```

# To list keys and add the signing key
# Source: https://docs.github.com/en/authentication/managing-commit-signature-verification/telling-git-about-your-signing-key
#
# 1. gpg --list-secret-keys --keyid-format=long
# 2. Copy the key ID.
# 3. git config --global user.signingkey <key ID>
# 4. git config --global commit.gpgsign true


# By default, invoke gpg
GPG_EXE=gpg
if grep -qi microsoft /proc/version || [[ "$OSTYPE" == "win32" ]]; then
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
