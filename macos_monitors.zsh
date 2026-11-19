#!/usr/bin/env zsh

# This script lists switches the primary monitor on macOS using display IDs.

function usage {
  echo -e "Usage:"
  echo -e "\t-l|--lg : Switch to LG monitor configuration."
  echo -e "\t-s|--samsung \t: Switch to Samsung monitor configuration."
  echo -e "\t-t|--toggle \t: Switch to the other monitor and turn this one off."
  echo -e "\t-h|--help \t: Print this message and exit."
}

# Resolve this before entering a function, where zsh sets $0 to the function name.
script_dir=${0:A:h}

# Persistent screen IDs from `displayplacer list`
lg_id=7B20B29E-3523-4BE3-8DFE-E6EEE210BA49
samsung_id=491AD0CD-224F-4B35-AB86-95C8459B6A0C

function monitor_id {
  [[ $1 == "samsung" ]] && echo $samsung_id || echo $lg_id
}

function is_online {
  displayplacer list | grep -q "^Persistent screen id: $1"
}

function bring_online {
  # Re-enable disabled displays if the given monitor is off. It can take a
  # moment to come online, and may not come back without replugging it.
  local id=$(monitor_id $1)
  is_online $id && return 0
  python3 $script_dir/macos_renabledisplays.py
  for attempt in {1..10} ; do
    sleep 0.5
    is_online $id && return 0
  done
  echo "ERROR: The $1 monitor is not online. Leaving the displays unchanged."
  return 1
}

function switch_display {
  # Turning off the other display while this one is offline would leave none on.
  bring_online $1 || return 1
  if [[ $1 == "samsung" ]] ; then
    # For Samsung:
    displayplacer "id:$samsung_id res:3840x2160 hz:30 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0" "id:$lg_id res:3440x1440 hz:50 color_depth:8 enabled:false scaling:off origin:(0,0) degree:0"
  elif [[ $1 == "lg" ]] ; then
    # For LG:
    displayplacer "id:$samsung_id res:3840x2160 hz:30 color_depth:8 enabled:false scaling:off origin:(0,0) degree:0" "id:$lg_id res:3440x1440 hz:50 color_depth:8 enabled:true scaling:off origin:(0,0) degree:0"
  fi
}

# if no argument provided, print usage and exit
zparseopts -D -E -F - l=lg -lg=lg s=samsung -samsung=samsung t=toggle -toggle=toggle h=help -help=help ||
  usage $0
echo "Found: " $help $lg $samsung $toggle
if [[ ! -z $help ]] ; then
  usage $0
  exit 0
elif [[ ! -z $lg ]] ; then
  echo "LG monitor selected"
  monitor="lg"
elif [[ ! -z $samsung ]] ; then
  echo "Samsung monitor selected"
  monitor="samsung"
elif [[ ! -z $toggle ]] ; then
  echo "Switching to the other monitor..."
  python3 $script_dir/macos_toggle_display.py
  exit $?
else
  exit 1
fi

echo "Switching to $monitor monitor configuration..."
switch_display $monitor
