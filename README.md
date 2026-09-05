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

Install the latest GitHub releases. Termux and every Termux add-on must come
from the same source so their signatures match.

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
pkg update && pkg upgrade -y
pkg install -y git
git clone https://github.com/suderman/termux ~/.termux
~/.termux/setup.sh
```

`setup.sh` is safe to rerun. For routine maintenance, `termux-update` first
rebases this repository onto its upstream branch, then updates packages,
plugins, service configuration, and scheduled jobs. Commit or stash phone-side
changes before running it.

Phone-side changes can be committed and pushed normally:

```sh
git -C ~/.termux add -A
git -C ~/.termux commit
git -C ~/.termux pull --rebase
git -C ~/.termux push
```

Before relying on remote access, put the desired public key in
`~/.ssh/authorized_keys`. SSH is configured for public-key authentication only.
Zsh is the default interactive shell; scripts use their explicit shebangs.

One-time Android setup:

1. Open Termux:Boot once so Android permits its boot receiver.
2. Set Termux battery usage to Unrestricted and allow its notifications.
3. Keep the permanent wake lock disabled. Boot and scheduled jobs take short locks while repairing services.
4. Start Shizuku before applying the optional Android settings below.

```sh
rish
sh /sdcard/Android/permission.sh
```

## Services

`sshd`, `mpd`, `mpd-url`, and `syncthing` run under `termux-services`.
`crond`, `mpdscribble`, and `hermes` are intentionally disabled.

```sh
sv status "$PREFIX/var/service/sshd"
sv log sshd
```

OpenSSH package upgrades recreate its `down` marker. The boot script, the
15-minute job, and the Tasker poke all run `sv-enable sshd` to repair it. A
healthy status must not include `normally down`.

If SSH is unavailable, open Termux locally and run:

```sh
export SVDIR="$PREFIX/var/service"
. "$PREFIX/etc/profile.d/start-services.sh"
sv-enable sshd
```
