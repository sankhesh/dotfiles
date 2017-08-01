#!/usr/bin/env bash


# Test if pyclewn is installed on the system
if [[ `python -c 'import pkgutil; \
  print(1 if pkgutil.find_loader("clewn") else 0)'` > "0" ]]; then
  printf "Pyclewn is installed.\nInstalling vim plugin..."
else
  echo -e "Pyclewn not installed on the system.\n"\
    "\n\t $ pip install pyclewn"
  exit 1
fi

(
## Get the pyclewn vimball
export VB=`python -c "import clewn; clewn.get_vimball()" \
  | sed -E "s/.* (\/.*.vmb)$/\\1/"`
mkdir -p $HOME/.vim/bundle/pyclewn # && cd $HOME/.vim/bundle/pyclewn

# Install the pyclewn plugin vimball
(vim --cmd "set rtp^=~/.vim/bundle/pyclewn" \
  $VB -c "UseVimball ~/.vim/bundle/pyclewn" +q >/dev/tty </dev/tty)
)
printf "Done\n"

if [[ $1 != '--dont-clean' ]]; then
  printf "Cleaning up vimball ..."
  rm -f .Vimball.sw*
  rm $VB
  printf "Done\n"
fi
