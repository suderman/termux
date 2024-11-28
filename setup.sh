#!/data/data/com.termux/files/usr/bin/bash
termux-wake-lock

# update packages
pkg update

# -- already exists --
# PREFIX=/data/data/com.termux/files/usr
# HOME=/data/data/com.termux/files/home
# -- add these too -- 
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.termux/config"
export TERMUX="$HOME/.termux"
export PATH="$HOME/bin:$TERMUX/bin:$PATH"

# Ensure these hidden directories are symlinked into ~/.termux/*
symlink $TERMUX/bin $HOME/bin
symlink $TERMUX/config $HOME/.config
symlink $TERMUX/shortcuts $HOME/.shortcuts

# termux tooling
pkg install -y termux-api termux-tools termux-services git

# configure all custom termux-services
for service in $TERMUX/services/*; do
  dir="$PREFIX/var/service/$(basename $service)"
  mkdir -p $dir
  ln -sf $PREFIX/share/termux-services/svlogger $dir/log/run
  cp -f $service $dir/run
done

# heartbeat every 15 minutes
termux-job-scheduler \
  --job-id=1 \
  --persisted=true \
  --period-ms 900000 \
  --script=$TERMUX/jobs/1.sh

# openssh
pkg install -y openssh  
sv-enable sshd
sv up sshd

# crond
pkg install -y cronie 
sv-enable crond
sv up crond

# bash
pkg install -y bash
symlink $XDG_CONFIG_HOME/bash/bashrc $HOME/.bashrc

# zsh + oh-my-zsh
pkg install -y zsh
symlink $XDG_CONFIG_HOME/zsh/zshrc $HOME/.zshrc
git-clone-pull https://github.com/ohmyzsh/ohmyzsh $XDG_DATA_HOME/oh-my-zsh

# nvim
pkg install -y neovim
dir="$XDG_DATA_HOME/nvim/site"
mkdir -p $dir/{autoload,plugged} # install vim-plug 
curl -fL https://github.com/junegunn/vim-plug/raw/master/plug.vim > $dir/autoload/plug.vim
nvim +PlugInstall +qall

# tmux
pkg install -y tmux
dir="$XDG_DATA_HOME/tmux/plugins"
mkdir -p $dir # install tmux plugin manager
git-clone-pull https://github.com/tmux-plugins/tpm $dir/tpm
$dir/tpm/bin/install_plugins

# yt-dlp
pkg install -y python                                                                                      u0_a377@localhost
pip install yt-dlp  

# mpd 
symlink $XDG_CONFIG_HOME/mpd $HOME/.mpd
pkg install -y mpd mpc
mkdir -p $XDG_DATA_HOME/mpd
sv-enable mpd
sv up mpd

# mpc-url
pkg install -y jq iconv wget netcat-openbsd # mpc-url dependencies
sv-enable mpc-url
sv up mpc-url
termux-job-scheduler \
  --job-id=2 \
  --persisted=true \
  --period-ms=7200000 \
  --script=$TERMUX/jobs/2.sh # every 2 hours

# mpdscribble
pkg install -y mpdscribble
sv-enable mpdscribble
sv up mpdscribble

# syncthing
pkg install -y syncthing
sv-enable syncthing
sv up syncthing

# everything else
pkg install -y build-essential file curl fzf fd yazi rsync mpv python ffmpeg neofetch imagemagick 

# copy script to directory where rish can execute
# > rish
# > sh /sdcard/Android/permission.sh
cp -f $TERMUX/permission.sh /sdcard/Android/permission.sh

# upgrade packages
pkg upgrade -y

# done
termux-wake-unlock
