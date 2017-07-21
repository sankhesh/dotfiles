#!/usr/bin/env bash

# Test if pyclewn is installed on the system
if [[ `python -c 'import pkgutil; \
  print(1 if pkgutil.find_loader("clewn") else 0)'` > "0" ]]; then
  echo "Pyclewn is installed"
else
  echo -e "Pyclewn not installed on the system.\n"\
    "\n\t $ pip install pyclewn"
  exit 1
fi

# Get the pyclewn vimball
export VB=`python -c "import clewn; clewn.get_vimball()" \
  | sed -E "s/.* (\/.*.vmb)$/\\1/"`
echo $VB
mkdir -p $HOME/.vim/bundle/pyclewn # && cd $HOME/.vim/bundle/pyclewn

# Install the pyclewn plugin vimball
(vim --cmd "set rtp^=~/.vim/bundle/pyclewn" \
  $VB -c "UseVimball ~/.vim/bundle/pyclewn" +q)
