#!/data/data/com.termux/files/usr/bin/bash
set -e

termux-wake-lock
trap termux-wake-unlock EXIT

export SVDIR="$PREFIX/var/service"
. "$PREFIX/etc/profile.d/start-services.sh"

# start-services.sh launches runsvdir in the background. Wait for its runsv
# processes, or sv-enable fails with "runsv not running" and set -e exits.
for _ in $(seq 30); do
  sv status sshd ssh-agent >/dev/null 2>&1 && break
  sleep 1
done
sv-enable sshd
sv-enable ssh-agent

# TermuxService stops once no task or wake lock remains, and Android then
# freezes the cached app with runsvdir and every service under it. Release the
# wake lock but stay running as a Termux:Boot task while runsvdir lives.
termux-wake-unlock
trap - EXIT
while kill -0 "$(cat "$PREFIX/var/run/service-daemon.pid")" 2>/dev/null; do
  sleep 300
done
