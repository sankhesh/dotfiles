// Background agent that binds Cmd+Shift+0 to `macos_monitors.zsh --toggle`,
// switching between the LG and the Samsung with only one of them on.
//
// Carbon hotkeys don't need Accessibility permission. Build and install it as a
// LaunchAgent with macos_monitor_hotkeys.zsh.

import AppKit
import Carbon.HIToolbox

setvbuf(stdout, nil, _IOLBF, 0)

guard CommandLine.arguments.count == 2 else {
  print("Usage: \(CommandLine.arguments[0]) /path/to/macos_monitors.zsh")
  exit(2)
}
let switchScript = CommandLine.arguments[1]
var running: Process?

func toggleMonitor() {
  // Ignore repeated presses while a switch is still in progress.
  if let process = running, process.isRunning {
    return
  }
  let process = Process()
  process.executableURL = URL(fileURLWithPath: "/bin/zsh")
  process.arguments = [switchScript, "--toggle"]
  do {
    try process.run()
    running = process
  } catch {
    print("Failed to run \(switchScript): \(error)")
  }
}

// This process registers a single hotkey, so every press is the toggle.
let onHotKey: EventHandlerUPP = { _, _, _ in
  toggleMonitor()
  return noErr
}

var pressed = EventTypeSpec(
  eventClass: OSType(kEventClassKeyboard),
  eventKind: UInt32(kEventHotKeyPressed))
InstallEventHandler(GetApplicationEventTarget(), onHotKey, 1, &pressed, nil, nil)

var hotKey: EventHotKeyRef?
let status = RegisterEventHotKey(
  UInt32(kVK_ANSI_0), UInt32(cmdKey | shiftKey),
  EventHotKeyID(signature: 0x6D6E_7472, id: 0),  // 'mntr'
  GetApplicationEventTarget(), 0, &hotKey)
if status != noErr {
  print("Failed to register Cmd+Shift+0: \(status)")
  exit(1)
}
print("Cmd+Shift+0 registered for \(switchScript)")

// Run without a Dock icon or menu bar.
NSApplication.shared.setActivationPolicy(.prohibited)
NSApplication.shared.run()
