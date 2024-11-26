#!/data/data/com.termux/files/usr/bin/bash

# -- already exists --
# PREFIX=/data/data/com.termux/files/usr
# HOME=/data/data/com.termux/files/home
# -- add these too -- 
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.termux/config"

# Path to local bin directory
bin=$HOME/.termux/bin

# Ensure these hidden directories are symlinked into ~/.termux/*
$bin/symlink $HOME/.termux/config $HOME/.config
$bin/symlink $HOME/.termux/shortcuts $HOME/.shortcuts

# termux tooling
pkg install -y termux-api termux-tools termux-services git

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
$bin/symlink $XDG_CONFIG_HOME/bash/bashrc $HOME/.bashrc

# zsh + oh-my-zsh
pkg install -y zsh
$bin/symlink $XDG_CONFIG_HOME/zsh/zshrc $HOME/.zshrc
$bin/git-clone-pull https://github.com/ohmyzsh/ohmyzsh $XDG_DATA_HOME/oh-my-zsh

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
$bin/git-clone-pull https://github.com/tmux-plugins/tpm $dir/tpm
$dir/tpm/bin/install_plugins

# yt-dlp
pkg install -y python                                                                                      u0_a377@localhost
pip install yt-dlp  

# mpd 
$bin/symlink $XDG_CONFIG_HOME/mpd $HOME/.mpd
pkg install -y mpd mpc
mkdir -p $XDG_DATA_HOME/mpd
sv-enable mpd
sv up mpd

# mpc-url
pkg install -y jq iconv wget netcat-openbsd # dependencies
# refresh every 2 hours
echo '#!/data/data/com.termux/files/usr/bin/sh' > $bin/mpc-url-refresh 
echo 'mpc-url flush && mpc-url update' >> $bin/mpc-url-refresh 
chmod +x $bin/mpc-url-refresh
termux-job-scheduler --job-id=1 --period-ms=7200000 --network=any --script=$bin/mpc-url-refresh
# refresh on playlist changes
dir="$PREFIX/var/service/mpc-url"
mkdir -p $dir/log 
ln -sf $PREFIX/share/termux-services/svlogger $dir/log/run # link the termux-logger
echo '#!/data/data/com.termux/files/usr/bin/sh' > $dir/run # write the service file for the application 
echo "exec termux-job-scheduler --job-id=1 --period-ms=7200000 --network=any --script=$bin/mpc-url-refresh 2>&1" >> $dir/run
echo "exec $bin/mpc-url flush 2>&1" >> $dir/run
echo "exec $bin/mpc-url update 2>&1" >> $dir/run
echo "exec $bin/mpc-url loop 2>&1" >> $dir/run
chmod +x $dir/run
sv-enable mpc-url
sv up mpc-url

# mpdscribble
pkg install -y mpdscribble
sv-enable mpdscribble
sv up mpdscribble

# syncthing
pkg install -y syncthing
dir="$PREFIX/var/service/syncthing"
mkdir -p $dir/log 
ln -sf $PREFIX/share/termux-services/svlogger $dir/log/run # link the termux-logger
echo '#!/data/data/com.termux/files/usr/bin/sh' > $dir/run # write the service file for the application 
echo "exec syncthing --no-browser --no-restart --logflags=0 --no-default-folder --gui-address=http://0.0.0.0:8384 2>&1" >> $dir/run
chmod +x $dir/run
sv-enable syncthing
sv up syncthing

# everything else
pkg install -y build-essential file curl fzf fd yazi rsync mpv python ffmpeg neofetch imagemagick 

# copy script to directory where rish can execute
# > rish
# > sh /sdcard/Android/permission.sh
cp -f ~/.termux/permission.sh /sdcard/Android/permission.sh
