#!/data/data/com.termux/files/usr/bin/bash
set -e

termux-wake-lock
trap termux-wake-unlock EXIT

export SVDIR="$PREFIX/var/service"
. "$PREFIX/etc/profile.d/start-services.sh"
sv-enable sshd
