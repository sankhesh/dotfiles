#!/usr/bin/env zsh

# Script to switch between discrete and embedded graphics for linux hybrid GPU laptops.
# Most of the time, I run everything on the Intel GPU with `prime-run` for visualization tasks on
# the NVIDIA GPU. However, when an external display is connected, I prefer switching to the dGPU
# like what Windows does automatically.
#
# This relies on an NVIDIA configuration file being copied over to /etc/X11/xorg.conf.d
# also available in this repository with the name `nvidia_conf`.
# While the script just renames the configuration, this is something that will avoid me having to
# reverse-engineer Xorg configurations next time.

function usage {
 echo -e "Usage:"
 echo -e "\tSwitch between NVIDIA and Intel GPUs for primary rendering."
 echo -e "\tEnable NVIDIA: 0"
 echo -e "\tEnable Intel: 1"
}

function contains {
  options="0 1"
  [[ $options =~ (^|[[:space:]])$1($|[[:space:]]) ]] && echo 0 || echo 1
}

CURRENT_DIR=$(realpath $(dirname $0))
echo $CURRENT_DIR

function switch {
  case $1 in
    0)
      ln -sf $CURRENT_DIR/nvidia_conf /etc/X11/xorg.conf.d/nvidia.conf
    ;;
    1)
      rm -f /etc/X11/xorg.conf.d/nvidia.conf
    ;;
    *)
      echo -e "\nERROR: Invalid option" "$opt\n"
      usage
      exit 1
    ;;
  esac
}

if [ "$#" -ne 0 ]; then
  echo "Parsing arugment: " $1
  opt=$1
else
  usage
  echo "Enter option:"
  read option
  opt=$option
fi

switch $opt
echo -e "Switched the GPU. Please restart X for changes to take effect"
exit 0
