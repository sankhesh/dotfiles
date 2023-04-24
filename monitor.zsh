#!/usr/bin/env zsh

# Script to automatically change the monitor resolution using xrandr.

function usage {
  echo -e "Usage:"
  echo -e "\t$1 (-x|--horizontal) X (-y|--vertical) Y [-r|--refresh] R [-h|--help]\n"
  echo -e "\t-x|--horizontal : Desired horizontal resolution (multiple of 8, required)."
  echo -e "\t-y|--vertical \t: Desired vertical resolution (required)."
  echo -e "\t-r|--refresh \t: Desired refresh rate (default: 30.0Hz)."
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

function get_modeline {
  # Given the resolution parameters, create a modeline using cvt

  # First, create a regex to parse cvt output
  reg="^Modeline\s+(.*)$"
  nreg="\"(.[^\s]*)\""
  cvt $1 $2 $3 | \
    while read line ; do
      if [[ $line =~ $reg ]] ; then
        ret=$match[1]
        if [[ $ret =~ $nreg ]] ; then
          nret=$match[1]
        fi
      fi
    done
  eval $4='$ret'
  eval $5='$nret'
}

# if no argument provided, print usage and exit
zparseopts -D -E -F - x:=x -horizontal:=x y:=y -vertical:=y r:=r -refresh:=r h=help -help=help ||
  usage $0
if [[ ! -z $help ]] ; then
  usage $0
  exit 0
elif [[ -z $x || -z $y || -z $r ]] ; then
  echo "ERROR: Missing required arguments."
  echo "Found $x $y $r\n"
  usage $0
  exit 1
fi

# Create a new mode for the resolution provided.
get_modeline $x[2] $y[2] $r[2] modeline modeline_name
m=${modeline//\"/}
# echo $=modeline
# echo $=modeline_name
xrandr --newmode $=m

# Create an empty array to store connected displays
res=()
# Fill the array with connected display names
get_displays res
# For each display, set the mode unless it is of type eDP* because that is the in-built display
edpreg="^eDP.*"
for r in $res;
  if [[ ! $r =~ $edpreg ]] ; then
    echo --addmode $r "$modeline_name"
    xrandr --addmode $r "$modeline_name"
  fi

exit 0
