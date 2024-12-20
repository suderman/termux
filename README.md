# termux config

## Usage

| volume button | shortcut key  | command                   |
| ------------- | ------------- | ------------------------- |
| `up`          | `q`           | toggle extra keys         |
| `up`          | `v`           | toggle volume control     |
| `up`          | `e`           | `esc`                     |
| `up`          | `t`           | `tab`                     |
| `up`          | `1`..`0`      | function keys `f1`..`f10` |
| `up`          | `wasd`        | arrow keys                |
| `up`          | `f`           | `alt-f`                   |
| `up`          | `b`           | `alt-b`                   |
| `up`          | `x`           | `alt-x`                   |
| `up`          | `l`           | pipe `|`                  |
| `up`          | `h`           | tilde `~`                 |
| `up`          | `u`           | underscore `_`            |
| `up`          | `p`           | `pgup`                    |
| `up`          | `n`           | `pgdn`                    |
| `up`          | `.`           | `ctrl-\`                  |
| `down`        | `any`         | `ctrl-any`                |

## Installation

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
rm -rf ~/.termux
git clone https://github.com/suderman/termux ~/.termux
bash .
~/.termux/setup.sh
```

```sh
rish
sh /sdcard/Android/permission.sh
```
