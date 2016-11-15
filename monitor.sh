#!/usr/bin/env bash

# Script to automatically change the monitor configuration using xrandr.
# Run xrandr to figure out the current monitor configuration as well as the
# ports / identifiers for each monitor.

# Turn off
echo "Three monitors connected."
echo "Turn on Samsung: 1"
echo "Turn off Samsung: 2"
echo "Turn on Dell : 3"
echo "Turn off Dell : 4"
echo "Enter option:"
read option
if [ $option = 1 ];
  then
    xrandr --output DVI-I-1 --off --noprimary
    xrandr --output DP-0 --off
    xrandr --output DP-3 --auto --primary

elif [ $option = 2 ];
  then
    xrandr --output DP-3 --off --noprimary
    xrandr --output DVI-I-1 --auto --primary
    xrandr --output DP-0 --auto --right-of DVI-I-1
    # Push the primary screen lower to align the bottom edges of the two
    # screens. Note that doing this in the same command as above does not seem
    # to work.
    xrandr --output DVI-I-1 --pos 0x120
elif [ $option = 3 ];
  then
    xrandr --output DP-0 --auto --right-of DVI-I-1
elif [ $option = 4 ];
  then
    xrandr --output DP-0 --off
fi
