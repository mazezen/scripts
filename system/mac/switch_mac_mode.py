#!/usr/bin/env python3

"""
This script let you turn on/off dark mode from the commandline on MacOS
python3 switch_mac_mode.py [options]
"""

import subprocess as sp
import sys
import platform
from os import system

CMD_TEMPLATE = """osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to {mode}'"""
GET_STATUS = "defaults read -g AppleInterfaceStyle"

def show_help():
    """
    Show this help message and exit.
    """
    help_message = """
    Usage: python3 switch_mac_mode.py [options]
    Options:
    --help -h    show help message
    <none>       Toggle dark mode
    on  dark     Enable Dark mode
    off light    Disable Dark mode
    status s     Dark mode status
    """
    print(help_message)

def status():
    """
    Get current status of MacOS. "Dark Mode" or "Light Mode".
    """
    try:
        s = sp.check_output(GET_STATUS.split(), stderr=sp.STDOUT).decode().strip()
        return "Dark Mode" if s == "Dark" else "Light Mode"
    except sp.CalledProcessError:
        return "Light Mode"


def set_mode(mode):
    # mode: True, False, or "not dark mode" for toggle
    cmd = CMD_TEMPLATE.format(mode=mode)
    print(cmd)
    sp.run(cmd, shell=True, check=True)


def main():
    """
       Main function
       """
    if platform.system() != "Darwin":
        print("This script only works on MacOS")
        sys.exit()

    if len(sys.argv) == 1:
        set_mode("Null")

    elif sys.argv[1] in ("on", "dark"):
        set_mode("True")
    elif sys.argv[1] in ("off", "light"):
        set_mode("False")
    elif sys.argv[1] in ("status", "s"):
        print(status())
    elif sys.argv[1] in ("--help", "-h"):
        show_help()
    else:
        print(f"Unknown option: {sys.argv[1]}")
        show_help()
        sys.exit()

if __name__ == '__main__':
   main()

