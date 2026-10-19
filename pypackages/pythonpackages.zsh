#!/usr/bin/env zsh

PYTHON_EXE=python3
if [[ $(uname -s) != "Darwin" ]] && grep -qi microsoft /proc/version || [[ "$OSTYPE" == "win32" ]]; then
  # For WSL, use python.exe
  PYTHON_EXE=python.exe
fi


# Get the relative path to the requirements file
# Using a relative path ensures that this script works across path difference in
# linux (eg: /home/..), wsl (eg: /mnt/c/..) etc.
relpath()
  {
    "$PYTHON_EXE" -c 'import posixpath, sys; print(posixpath.relpath(sys.argv[1], sys.argv[2]), end="")' "$1" "${2:-${PWD:A}}"
  }
REQPATH=$(relpath "${0:A:h}/requirements.txt" "${PWD:A}") || exit $?
REQPATH=${REQPATH%$'\r'}
ERROROUT="$("$PYTHON_EXE" -m pip install -r "$REQPATH" 2>&1)"
PIP_STATUS=$?
if (( PIP_STATUS == 0 )); then
  print -r -- "$ERROROUT"
elif [[ "$ERROROUT" == *"error: externally-managed-environment"* ]]; then
  echo "Breaking system packages."
  "$PYTHON_EXE" -m pip install --break-system-packages -r "$REQPATH"
else
  print -ru2 -- "$ERROROUT"
  exit "$PIP_STATUS"
fi
