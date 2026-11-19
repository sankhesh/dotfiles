#!/usr/bin/env python3

# Switch to the other display on macOS, keeping only one display on.
#
# With one display on, this turns on a display that is off, waits for it to
# come online and then turns the current one off. With several on, it keeps the
# first one that isn't the main display. Displays are turned off for the login
# session only, since a display disabled permanently may not come back without
# replugging it.

import sys
import time
from ctypes import (CDLL, util, c_void_p, c_uint32, c_int, c_bool, POINTER,
                    byref)

cg = CDLL(util.find_library('CoreGraphics'))

cg.CGBeginDisplayConfiguration.argtypes = [POINTER(c_void_p)]
cg.CGBeginDisplayConfiguration.restype = c_int
cg.CGCompleteDisplayConfiguration.argtypes = [c_void_p, c_uint32]
cg.CGCompleteDisplayConfiguration.restype = c_int
cg.CGCancelDisplayConfiguration.argtypes = [c_void_p]
cg.CGCancelDisplayConfiguration.restype = c_int
cg.CGSConfigureDisplayEnabled.argtypes = [c_void_p, c_uint32, c_bool]
cg.CGSConfigureDisplayEnabled.restype = c_int
cg.CGMainDisplayID.restype = c_uint32

kCGConfigureForSession = 1
MAX_DISPLAYS = 16
ONLINE_TIMEOUT = 10


def display_list(get_list):
    ids = (c_uint32 * MAX_DISPLAYS)()
    count = c_uint32()
    get_list(MAX_DISPLAYS, ids, byref(count))
    return list(ids[:count.value])


def online_displays():
    return display_list(cg.CGGetOnlineDisplayList)


def set_enabled(display_id, enabled):
    config_ref = c_void_p()
    if cg.CGBeginDisplayConfiguration(byref(config_ref)) != 0:
        return False
    if cg.CGSConfigureDisplayEnabled(config_ref, display_id, enabled) != 0:
        cg.CGCancelDisplayConfiguration(config_ref)
        return False
    return cg.CGCompleteDisplayConfiguration(
        config_ref, kCGConfigureForSession) == 0


def bring_other_online(current):
    # The list includes displays that are off, along with ones that are gone.
    # Enabling a display that is gone fails, so try them all.
    for display_id in display_list(cg.CGSGetDisplayList):
        if display_id not in current:
            set_enabled(display_id, True)
    deadline = time.monotonic() + ONLINE_TIMEOUT
    while time.monotonic() < deadline:
        added = [d for d in online_displays() if d not in current]
        if added:
            return added[0]
        time.sleep(0.25)
    return None


def main():
    online = online_displays()
    others = [d for d in online if d != cg.CGMainDisplayID()]
    if others:
        target = others[0]
    else:
        target = bring_other_online(online)
        if target is None:
            print("ERROR: No other display came online. "
                  "Leaving the displays unchanged.")
            return 1

    for display_id in online_displays():
        if display_id != target and not set_enabled(display_id, False):
            print(f"ERROR: Failed to turn off display {display_id}.")
            return 1
    print(f"Switched to display {target}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
