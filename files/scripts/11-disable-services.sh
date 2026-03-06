#!/usr/bin/env bash

set -xeuo pipefail

# Printing
systemctl mask cups.service cups.socket cups-browsed.service

# mDNS (Avahi)
systemctl mask avahi-daemon.service avahi-daemon.socket

# Modem Manager (no mobile modems on thin client)
systemctl mask ModemManager.service

# Crash/debug reporting (ABRT)
systemctl mask abrtd.service abrt-oops.service abrt-xorg.service abrt-journal-core.service

# Core dumps
systemctl mask systemd-coredump.socket
