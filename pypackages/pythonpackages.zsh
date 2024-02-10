#!/usr/bin/env zsh

set PYTHON_EXE=python
if grep -qi microsoft /proc/version || [[ "$OSTYPE" == "win32" ]]; then
  # For WSL, use python.exe
  PYTHON_EXE=python.exe
fi

# Get the relative path to the requirements file
# Using a relative path ensures that this script works across path difference in
# linux (eg: /home/..), wsl (eg: /mnt/c/..) etc.
REQPATH=`realpath --relative-to=${PWD} ${0:a:h}/requirements.txt`
$PYTHON_EXE -m pip install -r $REQPATH
