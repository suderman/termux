#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

termux-wake-lock
trap termux-wake-unlock EXIT

export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.termux/config"
export TERMUX="$HOME/.termux"
export PATH="$HOME/bin:$TERMUX/bin:$PATH"
export SVDIR="$PREFIX/var/service"
export LOGDIR="$PREFIX/var/log"

# update packages
pkg update -y
pkg upgrade -y

# OpenSSH upgrades recreate this marker. Repair it before slower setup steps.
if command -v sv-enable >/dev/null && [ -d "$SVDIR/sshd" ]; then
  sv-enable sshd
fi

# Ensure these hidden directories are symlinked into ~/.termux/*
symlink "$TERMUX/bin" "$HOME/bin"
symlink "$TERMUX/config" "$HOME/.config"
symlink "$TERMUX/shortcuts" "$HOME/.shortcuts"

# shared Termux and Emacs homes
if [ -L "$HOME/src" ] || { [ -e "$HOME/src" ] && [ ! -d "$HOME/src" ]; }; then
  echo "Expected a directory at $HOME/src" >&2
  exit 1
fi
mkdir -p "$HOME/src"

symlink /storage/emulated/0 "$HOME/storage"
symlink /storage/emulated/0/Org "$HOME/org"

# Force terminal Emacs to use the Android Emacs app's config.
rm -rf -- "$HOME/.emacs" "$HOME/.emacs.el" "$HOME/.emacs.elc" "$HOME/.emacs.d"

emacs_home=/data/data/org.gnu.emacs/files
if [ -d "$emacs_home" ] && [ -w "$emacs_home" ]; then
  symlink "$emacs_home" "$HOME/emacs"
  symlink "$emacs_home/.config/emacs" "$HOME/.config/emacs"
  symlink /storage/emulated/0 "$emacs_home/storage"
  symlink /storage/emulated/0/Org "$emacs_home/org"
  symlink "$HOME" "$emacs_home/termux"
  symlink "$HOME/src" "$emacs_home/src"
else
  echo "Warning: Emacs app home is unavailable: $emacs_home" >&2
fi

# termux tooling
pkg install -y gh git termux-tools termux-api termux-services

# Heartbeat every 15 minutes. Termux:API 0.53 crashes while formatting jobs
# with no network constraint, so use "any" until the app fixes that bug.
termux-job-scheduler \
  --job-id=1 \
  --persisted=true \
  --period-ms 900000 \
  --network=any \
  --battery-not-low=false \
  --script="$TERMUX/jobs/1.sh"

# openssh
pkg install -y openssh
mkdir -p "$PREFIX/etc/ssh/sshd_config.d"
ln -sf "$XDG_CONFIG_HOME/ssh/sshd_config.d/termux.conf" \
  "$PREFIX/etc/ssh/sshd_config.d/termux.conf"

# bash
pkg install -y bash
symlink "$XDG_CONFIG_HOME/bash/bashrc" "$HOME/.bashrc"

# zsh + oh-my-zsh
pkg install -y zsh
symlink "$XDG_CONFIG_HOME/zsh/zshrc" "$HOME/.zshrc"
git-clone-pull https://github.com/ohmyzsh/ohmyzsh "$XDG_DATA_HOME/oh-my-zsh"
zsh -n "$HOME/.zshrc"
chsh -s zsh

# nvim
pkg install -y neovim
dir="$XDG_DATA_HOME/nvim/site"
mkdir -p "$dir"/{autoload,plugged} # install vim-plug
curl -fL https://github.com/junegunn/vim-plug/raw/master/plug.vim \
  --output "$dir/autoload/plug.vim"
nvim --headless '+PlugUpgrade' '+PlugUpdate --sync' '+qall'

# tmux
pkg install -y tmux
dir="$XDG_DATA_HOME/tmux/plugins"
mkdir -p "$dir" # install tmux plugin manager
git-clone-pull https://github.com/tmux-plugins/tpm "$dir/tpm"
"$dir/tpm/bin/install_plugins"
"$dir/tpm/bin/update_plugins" all

# yt-dlp
pkg install -y python
python -m pip install --upgrade yt-dlp

# mpd 
symlink "$XDG_CONFIG_HOME/mpd" "$HOME/.mpd"
pkg install -y mpd mpc
mkdir -p "$XDG_DATA_HOME/mpd/playlists"

# mpd-url
pkg install -y jq curl netcat-openbsd # mpd-url dependencies
git-clone-pull https://github.com/suderman/mpd-url "$XDG_DATA_HOME/mpd-url"
cp -f "$XDG_DATA_HOME/mpd-url/mpd-url" "$HOME/bin/mpd-url"
termux-fix-shebang "$HOME/bin/mpd-url"
termux-job-scheduler \
  --job-id=2 \
  --persisted=true \
  --period-ms=7200000 \
  --network=any \
  --script="$TERMUX/jobs/2.sh" # every 2 hours

# syncthing
pkg install -y syncthing

# hermes-agent
# curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | bash 
# if install gets stuck:
# cd ~/.hermes/hermes-agent
# python -m venv venv
# source venv/bin/activate
# export ANDROID_API_LEVEL="$(getprop ro.build.version.sdk)"
# python -m pip install --upgrade pip setuptools wheel
# python -m pip install -e '.[termux]' -c constraints-termux.txt
#
# disabling hermes for now

# everything else
pkg install -y build-essential file fzf fd yazi rsync mpv ffmpeg neofetch imagemagick

# configure custom termux-services after their dependencies are installed
for service in "$TERMUX"/services/*; do
  name="$(basename "$service")"
  dir="$SVDIR/$name"
  mkdir -p "$dir/log"
  ln -sf "$PREFIX/share/termux-services/svlogger" "$dir/log/run"
  cp -f "$service" "$dir/run"
done

# Package upgrades restore sshd's down marker, so enable services last.
touch "$SVDIR/hermes/down"
. "$PREFIX/etc/profile.d/start-services.sh"
sv-enable sshd
sv-enable mpd
sv-enable mpd-url
sv-enable syncthing

for service in crond mpdscribble hermes; do
  if [ -d "$SVDIR/$service" ]; then
    sv-disable "$service"
  fi
done

termux-reload-settings

if tmux list-sessions >/dev/null 2>&1; then
  tmux source-file "$XDG_CONFIG_HOME/tmux/tmux.conf"
fi

sshd -t
for service in sshd mpd mpd-url syncthing crond mpdscribble hermes; do
  if [ -d "$SVDIR/$service" ]; then
    sv status "$service"
  fi
done
git -C "$TERMUX" status --short --branch

# copy script to directory where rish can execute
# > rish
# > sh /sdcard/Android/permission.sh
cp -f "$TERMUX/permission.sh" /sdcard/Android/permission.sh
