#!/usr/bin/env zsh

# Script to disable the NetworkManager hotspot login check that keeps a GNOME from accepting a
# password. This script creates a bypass conf based on
# https://unix.stackexchange.com/questions/419422/wifi-disable-hotspot-login-screen

conf_file="/etc/NetworkManager/conf.d/20-connectivity.conf"
if [ -f $conf_file ]; then
  echo "File $conf_file exists. Renaming to 20-connectivity_conf.backup"
  mv $conf_file /etc/NetworkManager/conf.d/20-connectivity_conf.backup
fi

# Create the empty file
touch $conf_file
exit 0
