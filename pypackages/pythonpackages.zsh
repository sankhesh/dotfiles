#!/usr/bin/env zsh

PYTHON_EXE=python
if grep -qi microsoft /proc/version || [[ "$OSTYPE" == "win32" ]]; then
  # For WSL, use python.exe
  PYTHON_EXE=python.exe
fi

# Get the relative path to the requirements file
# Using a relative path ensures that this script works across path difference in
# linux (eg: /home/..), wsl (eg: /mnt/c/..) etc.
REQPATH=`realpath --relative-to=${PWD} ${0:a:h}/requirements.txt`
ERROROUT="$( $PYTHON_EXE -m pip install -r $REQPATH 2>&1 > /dev/null )"
if [[ "$ERROROUT" =~ externally-managed-environment ]];
then
  echo "Breaking system packages."
  $PYTHON_EXE -m pip install --break-system-packages -r $REQPATH
fi
