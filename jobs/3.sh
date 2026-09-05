#!/data/data/com.termux/files/usr/bin/bash
set -e

termux-wake-lock
trap termux-wake-unlock EXIT

/data/data/com.termux/files/home/.termux/shortcuts/tasks/daily-notes
