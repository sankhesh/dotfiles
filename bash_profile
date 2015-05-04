# git bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

export PATH=/Applications/CMake.app/Contents/bin:$PATH

# Custom prompt
source ${HOME}/.bash_prompt
