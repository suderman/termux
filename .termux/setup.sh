# rm -rf $HOME/.shortcuts
# ln -s $HOME/.termux/shortcuts $HOME/.shortcuts

# mpd configuared to use this directory
mkdir -p $HOME/.local/share/mpd

pkg install -y syncthing

# create syncthing service
dir=$PREFIX/var/service/syncthing
if [[ ! -e "$dir" ]]; then

  # link the termux-logger
  mkdir -p $dir/log
  ln -sf $PREFIX/share/termux-services/svlogger $dir/log/run
  
  # write the service file for the application 
  echo "#!/data/data/com.termux/files/usr/bin/sh" > $dir/run
  echo "exec syncthing --no-browser --no-restart --logflags=0 --no-default-folder --gui-address=http://0.0.0.0:8384 2>&1" >> $dir/run
  chmod +x $dir/run

fi

# start it at boot
sv-enable syncthing
