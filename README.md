# termux config

Install the latest:
- [termux](https://github.com/termux/termux-app/releases)
- [termux-api](https://github.com/termux/termux-api/releases)
- [termux-boot](https://github.com/termux/termux-boot/releases)
- [termux-styling](https://github.com/termux/termux-styling/releases)
- [termux-widget](https://github.com/termux/termux-widget/releases)
- [termux-float](https://github.com/termux/termux-float/releases)
- [termux-tasker](https://github.com/termux/termux-tasker/releases)
- [tasker](https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm&hl=en_CA)
- [shizuku](https://github.com/RikkaApps/Shizuku/releases)

```sh
pkg update
pkg upgrade
pkg install git
rm -rf .termux/
cd ..
git clone https://github.com/suderman/termux home/
cd home/
bash ./termux/setup.sh
```

