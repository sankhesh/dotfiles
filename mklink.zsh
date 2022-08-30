#!/usr/bin/env zsh

# Script to use mklink in wsl for creating symlinks to files and directories in Windows.
# To make it easier to access this script, I create an alias to this script in zshrc.

zmodload zsh/zutil
zparseopts -D -E -F - h=help J=junc H=hl D=dsym

function echoerr() {
  echo "ERROR: $@" 1>&2;
}

function usage {
  echo -e "USAGE:"
  echo -e "\tmklink - Create symbolic links in wsl that work from Windows prompt too."
  echo -e "\n\tTypical usage:"
  echo -e "\t\tmklink <optional switch> <new link> <existing target>"
  echo -e "\n\tSwitches:"
  echo -e "\t-h\t Print this help message"
  echo -e "\t-H\t Create a hard link"
  echo -e "\t-J\t Create a directory junction"
}

if [ $help ]; then
  usage
  return
fi

argn=$#
if [ $argn -lt 1 ]; then
  echoerr "Missing arguments"
  usage
  return
fi

echo -e "Using cmd:"
echo -e "mklink"${dsym//-/ /}""${junc//-/ /}""${hl//-/ /}" "${1//\//\\\\}" "${2//\//\\\\}
echo -e "\n"

cmd.exe /c "mklink"${dsym//-/ /}""${junc//-/ /}""${hl//-/ /}" "${1//\//\\\\}" "${2//\//\\\\}

# Alias: mklink=" . mklink.zsh"
# USAGE: mklink <mylink> <target>
