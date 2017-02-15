#!/usr/bin/env bash

# Script to automatically change the monitor configuration using xrandr.
# Run xrandr to figure out the current monitor configuration as well as the
# ports / identifiers for each monitor.

function usage {
 echo -e "Usage:"
 echo -e "\tThree monitors connected."
 echo -e "\tTurn on Samsung: 1"
 echo -e "\tTurn off Samsung: 2"
 echo -e "\tTurn on Dell : 3"
 echo -e "\tTurn off Dell : 4"
}

function contains {
  options="1 2 3 4"
  [[ $options =~ (^|[[:space:]])$1($|[[:space:]]) ]] && echo 0 || echo 1
}

function switch {
  case $1 in
    1)
      xrandr --output DVI-I-1 --off --noprimary
      xrandr --output DP-0 --off
      xrandr --output DP-3 --auto --primary
    ;; 
    2)
      xrandr --output DP-3 --off --noprimary
      xrandr --output DVI-I-1 --auto --primary
      xrandr --output DP-0 --auto --right-of DVI-I-1
      # Push the primary screen lower to align the bottom edges of the two
      # screens. Note that doing this in the same command as above does not seem
      # to work.
      xrandr --output DVI-I-1 --pos 0x120
    ;;
    3)
      xrandr --output DP-0 --auto --right-of DVI-I-1
    ;;
    4)
      xrandr --output DP-0 --off
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
exit 0
