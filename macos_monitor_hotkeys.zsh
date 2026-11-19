#!/usr/bin/env zsh

# Installs a LaunchAgent that binds Super+Shift+0 (Cmd+Shift+0) to switch
# between the LG and the Samsung, keeping only one of them on, using
# macos_monitors.zsh.

function usage {
  echo -e "Usage:"
  echo -e "\t$1 [-u|--uninstall] [-h|--help]\n"
  echo -e "\t-u|--uninstall : Remove the monitor hotkey agent."
  echo -e "\t-h|--help \t: Print this message and exit."
}

script_dir=${0:A:h}
label=local.dotfiles.monitor-hotkeys
binary=$HOME/.local/bin/monitor-hotkeys
plist=$HOME/Library/LaunchAgents/$label.plist
log=$HOME/Library/Logs/monitor-hotkeys.log

zparseopts -D -E -F - u=uninstall -uninstall=uninstall h=help -help=help || {
  usage $0
  exit 1
}
if [[ ! -z $help ]] ; then
  usage $0
  exit 0
fi

# Stop any running copy before replacing or removing it.
launchctl bootout gui/$UID/$label 2>/dev/null

if [[ ! -z $uninstall ]] ; then
  rm -f $binary $plist
  echo "Removed the monitor hotkey agent."
  exit 0
fi

mkdir -p ${binary:h} ${plist:h} ${log:h}
echo "Building $binary..."
swiftc -O -o $binary $script_dir/macos_monitor_hotkeys.swift || exit 1

# launchd doesn't use the login shell PATH, so add Homebrew for displayplacer.
cat > $plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$label</string>
  <key>ProgramArguments</key>
  <array>
    <string>$binary</string>
    <string>$script_dir/macos_monitors.zsh</string>
  </array>
  <key>EnvironmentVariables</key>
  <dict>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
  </dict>
  <key>RunAtLoad</key>
  <true/>
  <key>KeepAlive</key>
  <dict>
    <key>Crashed</key>
    <true/>
  </dict>
  <key>ProcessType</key>
  <string>Interactive</string>
  <key>StandardOutPath</key>
  <string>$log</string>
  <key>StandardErrorPath</key>
  <string>$log</string>
</dict>
</plist>
EOF

launchctl bootstrap gui/$UID $plist || exit 1
echo "Installed. Cmd+Shift+0 switches between the LG and Samsung monitors."
echo "Log: $log"
