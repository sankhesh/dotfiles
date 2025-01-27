#!/usr/bin/env zsh

# Script to switch between two monitors connected to DP-0 and DP-4. 
# Current version has the numbers hard-coded but can be customized
# if the setup changes in the future.
#
# Uses xrandr and full resolutions

function usage {
  echo -e "Usage:"
  echo -e "\t$1 (-t|--target) M [-h|--help]\n"
  echo -e "\t-t|--target : Desired target monitor (0, 1)."
  echo -e "\t-h|--help \t: Print this message and exit."
}

function get_displays {
  # Create an empty connected displays array
  conn_disps=()

  # xrandr output is typically something like:
  #
  #DP-1-3 connected primary 3440x1440+0+0 (normal left inverted right x axis y axis) 819mm x 346mm
  #
  # The following regex is set up to parse the name of the displays
  reg="^(\w+[-0-9]+)\s+.+$"

  # Get the display names and push it to the array
  xrandr | grep " connected" | \
    while read line ; do
      if [[ $line =~ $reg ]] ; then
        conn_disps+=$match[1]
      fi
    done

  # Return the array using the passed in parameter to the function.
  # Ref: https://unix.stackexchange.com/questions/535118/whats-the-idiomatic-way-of-returning-an-array-in-a-zsh-function
  local arrayName=${1:-reply}; shift
  : ${(PA)arrayName::="${conn_disps[@]}"}
}

# if no argument provided, print usage and exit
zparseopts -D -E -F - t:=t -target:=t h=help -help=help ||
  usage $0
if [[ ! -z $help ]] ; then
  usage $0
  exit 0
elif [[ -z $t ]] ; then
  echo "ERROR: Missing required arguments."
  echo "Found $t\n"
  usage $0
  exit 1
fi

# Create an empty array to store connected displays
dsp=()
# Fill the array with connected display names
get_displays dsp
echo "Detected displays $dsp"

ct=$t[2]
if [[ $ct == 0 ]]; then
  echo "Switching to DP-0"
  xrandr --output DP-0 --mode 3840x2160 --primary --auto --output DP-4 --off
else
  echo "Switching to DP-4"
  xrandr --output DP-4 --mode 3440x1440 --primary --auto --output DP-0 --off
fi
