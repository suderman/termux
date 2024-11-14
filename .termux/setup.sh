#!/data/data/com.termux/files/usr/bin/bash

# -- already exists --
# PREFIX=/data/data/com.termux/files/usr
# HOME=/data/data/com.termux/files/home
# -- add these too -- 
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"

# termux tooling
pkg install -y termux-api termux-tools termux-services

# openssh
pkg install -y openssh  
sv-enable sshd
sv up sshd

# crond
pkg install -y cronie 
sv-enable crond
sv up crond

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
[ -e $dir/tpm ] && git pull || git clone https://github.com/tmux-plugins/tpm $dir/tpm
$dir/tpm/bin/install_plugins

# mpd 
pkg install -y mpd mpc
dir="$XDG_DATA_HOME/mpd"
mkdir -p $dir
sv-enable mpd
sv up mpd

# mpdscribble
pkg install -y mpdscribble
sv-enable mpdscribble
sv up mpdscribble

# syncthing
pkg install -y syncthing
dir="$PREFIX/var/service/syncthing"
mkdir -p $dir/log 
ln -sf $PREFIX/share/termux-services/svlogger $dir/log/run # link the termux-logger
echo "#!/data/data/com.termux/files/usr/bin/sh" > $dir/run # write the service file for the application 
echo "exec syncthing --no-browser --no-restart --logflags=0 --no-default-folder --gui-address=http://0.0.0.0:8384 2>&1" >> $dir/run
chmod +x $dir/run
sv-enable syncthing
sv up syncthing

# everything else
pkg install -y build-essential file curl zsh fzf fd yazi rsync mpv python ffmpeg neofetch imagemagick 
