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
    $PYTHON_EXE -c "from pathlib import Path,PurePosixPath; print(PurePosixPath(Path('$1').relative_to(Path('${2:-${PWD:A}}'), walk_up=True)), end='');"
  }
REQPATH=$(relpath ${0:A:h}/requirements.txt ${PWD:A})
ERROROUT="$( $PYTHON_EXE -m pip install -r ${REQPATH%\\r} 2>&1 > /dev/null )"
if [[ "$ERROROUT" =~ "error: externally-managed-environment" ]];
then
  echo "Breaking system packages."
  $PYTHON_EXE -m pip install --break-system-packages -r ${REQPATH%\\r}
fi
