#!/usr/bin/env bash

if [ "$(uname)" == "Darwin" ]; then
  echo "Running Mac OSX. Skip installing additional fonts."
  exit 0
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
  echo "Detected Linux system."
  echo -n "Install additional fonts [y/N]: "
  read -n 1 accept
  echo
  if [ "$accept" == "y" -o "$accept" == "Y" ]; then
    echo -n "Installing additional fonts..."
    curl -kL https://raw.github.com/cstrap/monaco-font/master/install-font-ubuntu.sh | bash
    if [ $? != 0 ]; then
      echo "FAILED: Installing additional fonts..."
      exit 1;
    else
      echo "SUCCESS: Installed additional fonts."
    fi
  else
    echo "Not installing additional fonts."
  fi
fi
exit 0
