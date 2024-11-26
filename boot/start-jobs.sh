#!/data/data/com.termux/files/usr/bin/bash
export PATH=$HOME/.termux/bin:$PATH

# refresh every 2 hours while connected to internet
termux-job-scheduler --job-id=1 --period-ms=7200000 --network=any --script=mpc-url-refresh
