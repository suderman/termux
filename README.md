# Termux and Android control

This repository contains vital Termux configuration for the Pixel 10 Pro named
`gem`. It also provides a small host-side ADB environment for inspecting and
operating the same phone under supervision. It does not include Android Studio,
a large SDK, a daemon, or a phone-side automation app.

## Development shell

On NixOS, enable direnv and nix-direnv in the system or Home Manager
configuration:

```nix
programs.direnv = {
  enable = true;
  nix-direnv.enable = true;
};
```

Review and allow this repository once:

```sh
cd ~/src/suderman/termux
direnv allow
```

The development shell then loads on entry. Without direnv, run `nix develop`.
It contains `adb`, `scrcpy`, `jq`, and these helpers:

| Command | Use |
| --- | --- |
| `android-status` | Require one authorized device and show device and display details. |
| `android-screenshot [PATH]` | Capture the screen. Default: `/tmp/android-control/screen.png`. |
| `android-ui [PATH]` | Capture UI XML. Default: `/tmp/android-control/window.xml`. |
| `android-tap X Y` | Tap one coordinate. |
| `android-swipe X1 Y1 X2 Y2 [DURATION_MS]` | Swipe between coordinates. |
| `android-type TEXT` | Enter one single-line text value. |
| `android-key KEYCODE` | Send an Android key event. |
| `android-open PACKAGE` | Launch an installed application's launcher activity. |

Raw `adb` remains available when a helper does not cover the task.

For normal development, edit tracked configuration on the host, review the
diff, and run the checks below before touching the phone. Repository edits do
not change the phone. Deploy only the intended files or service state after
review; do not rerun all of `setup.sh` for a small change.

## Android setup and operation

USB debugging setup requires manual action on the phone:

1. Enable Developer Options and USB debugging.
2. Connect the phone over USB.
3. Unlock or allow the connection if GrapheneOS USB restrictions require it.
4. Review and accept the Android RSA debugging authorization prompt.
5. Run `android-status` on the host. It explains missing, unauthorized, offline, and multiple-device failures.

Do not try to automate Developer Options, USB debugging, lock-screen
authentication, the RSA prompt, or another GrapheneOS protection.

Start an inspection session with:

```sh
android-status
android-screenshot
android-ui
scrcpy
```

Use ADB for control and scrcpy for the supervised live view. Observe the screen
or UI hierarchy, perform one action, and verify the result before continuing.
See [`AGENTS.md`](AGENTS.md) for the full safety loop, command details, package
names, and Tasker guidance.

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

## Fresh-phone bootstrap

Manually obtain Termux and each Termux add-on from the same trusted source so
their signatures match. The repository does not download or install APKs. The
official project release pages are:

- [termux](https://github.com/termux/termux-app/releases)
- [termux-api](https://github.com/termux/termux-api/releases)
- [termux-boot](https://github.com/termux/termux-boot/releases)
- [termux-styling](https://github.com/termux/termux-styling/releases)
- [termux-widget](https://github.com/termux/termux-widget/releases)
- [termux-float](https://github.com/termux/termux-float/releases)
- [termux-tasker](https://github.com/termux/termux-tasker/releases)
- [tasker](https://play.google.com/store/apps/details?id=net.dinglisch.android.taskerm&hl=en_CA)
- [shizuku](https://github.com/RikkaApps/Shizuku/releases)

On a fresh phone:

1. Install the reviewed APKs manually and approve Android installation prompts yourself.
2. Open Termux once. Run `termux-setup-storage` if shared storage is wanted, then approve its Android permission prompt.
3. Inspect `~/.termux`. If it already contains configuration, preserve it and stop for explicit approval before replacing anything.
4. Only when `~/.termux` is absent or approved for this repository, bootstrap it:

```sh
pkg update && pkg upgrade -y
pkg install -y git
git clone https://github.com/suderman/termux ~/.termux
git -C ~/.termux status --short --branch
```

5. Review `~/.termux/setup.sh`, especially its managed links and legacy Emacs paths, then run it only after approving those live-phone changes:

```sh
~/.termux/setup.sh
```

6. Put the desired public key in `~/.ssh/authorized_keys` before relying on remote access. SSH permits public-key authentication only.
7. Open Termux:Boot once, allow Termux notifications, and manually set Termux battery usage to Unrestricted. Keep the permanent wake lock disabled.

`setup.sh` manages packages, links, services, scheduled jobs, and selected
runtime copies. It removes legacy `~/.emacs*` and `~/.emacs.d` paths so Emacs
uses the configured XDG location. It is idempotent for the expected managed
state, but it is not a backup or discovery step. Inspect and get explicit
approval before running it against existing Termux files or app data.

For routine maintenance, `termux-update` requires a clean phone-side worktree,
rebases it onto upstream, and runs `setup.sh`. It never commits or pushes.

Phone-side changes can be committed and pushed normally:

```sh
git -C ~/.termux add -A
git -C ~/.termux commit
git -C ~/.termux pull --rebase
git -C ~/.termux push
```

Zsh is the default interactive shell; scripts use their explicit shebangs.

## Shared files

`setup.sh` keeps these links consistent between Termux and the custom Emacs
APK:

```text
Termux home                     Target
~/storage                       /storage/emulated/0
~/org                           /storage/emulated/0/Org
~/emacs                         /data/data/org.gnu.emacs/files
~/.config/emacs                 /data/data/org.gnu.emacs/files/.config/emacs

Emacs app home                  Target
~/storage                       /storage/emulated/0
~/org                           /storage/emulated/0/Org
~/termux                        /data/data/com.termux/files/home
~/src                           /data/data/com.termux/files/home/src
```

Termux owns the real `~/src` directory. The Emacs APK owns its
`~/.config/emacs` Git repository. Setup removes Termux's legacy `~/.emacs`,
`~/.emacs.el`, `~/.emacs.elc`, and `~/.emacs.d` paths so terminal Emacs loads
the APK-owned config through `~/.config/emacs`. If the Emacs app home is not
installed or writable, setup warns and continues.

Optional Android-side setup requires more manual approval:

1. Open Termux:Boot once so Android permits its boot receiver.
2. Set Termux battery usage to Unrestricted and allow its notifications.
3. Keep the permanent wake lock disabled. Boot and scheduled jobs take short locks while repairing services.
4. Start Shizuku manually and approve its prompts before applying the optional settings below.
5. Review `permission.sh`. It changes a global Android setting and grants Tasker permissions, so run it only with explicit approval.

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
