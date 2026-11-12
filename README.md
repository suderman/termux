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

`android-settings.conf` records Android settings the phone should have, some of
which GrapheneOS hides: holding power opens the digital assistant, and power with
volume up opens the power menu. `android-settings check` compares the phone with
it and exits 1 on a difference; `android-settings apply` writes what differs.
Add a line there whenever a setting is changed over ADB, so a rebuilt phone gets
it back.

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
8. From the development host, restore the Android settings GrapheneOS keeps out of its Settings app, then check them:

```sh
android-settings apply
android-settings check
```

9. Install June (`nix run .#android-install` in the June repository) and select it under Settings, Apps, Default apps, Digital assistant app. Holding power then opens June, and power with volume up opens the power menu.

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

## Launcher shortcuts

`setup.sh` links `shortcuts/` to `~/.shortcuts`, where Termux:Widget finds
scripts for its home-screen widget. To also search and run a script from the
KISS launcher like an app, pin it:

1. Add the script to `shortcuts/` and make it executable.
2. Open Termux:Widget's shortcut creator and tap the script. The launcher
   accepts the pin request.
3. Search the script's name in KISS.

KISS hides the shortcuts of any app it excludes, so Termux:Widget must not be
excluded in KISS, even though the other Termux add-ons can be. Pins live in
Android's shortcut service, not in this repository, so reinstalling
Termux:Widget or KISS means pinning again.

## Terminal font

`setup.sh` links `~/.termux/font.ttf` to
`jon/profile/fonts/CommitMono/CommitMonoNerdFontMono-Termux.ttf` on shared
storage, which Syncthing keeps current. Termux has no font fallback, so that
file is `CommitMono Nerd Font Mono` with missing symbols, such as Claude Code's
`⏵`, copied in from Ioskeley Mono. Rebuild it with `build.sh` in the same
folder on a NixOS host. Termux loads a changed font only after the app is
killed and relaunched; `termux-reload-settings` is not enough.

`install-termux-font` installs the pinned, unpatched official release instead.
It refuses to replace a linked `font.ttf`, so remove the link first to use it;
the next `setup.sh` run then stops at the font link until that file is removed.
The helper verifies both the Nerd Fonts archive and selected regular face,
preserves the prior font as `~/.termux/font.ttf.before-commit-mono`, and
reloads Termux settings.

Restore the previous font with:

```sh
mv ~/.termux/font.ttf.before-commit-mono ~/.termux/font.ttf
termux-reload-settings
```

## Herdr

Herdr's official `herdr-linux-aarch64` release is a static Linux binary that
runs natively in Termux, without proot. Herdr's installer refuses Android, so
`install-herdr` installs and updates it instead:

```sh
install-herdr --check   # installed and latest stable versions; exits 1 when behind
install-herdr           # install, or update to the latest stable release
install-herdr 0.9.4     # pin or roll back to a release
```

It reads the release from GitHub's API and refuses an asset without GitHub's
SHA-256 digest. It checks the download against that digest and checks that
the new binary reports the expected version before renaming it over
`$PREFIX/bin/herdr`. Any failure leaves the installed binary in place.
`setup.sh` runs it, so `termux-update` keeps Herdr current; a pinned version
lasts until the next setup run. A running local Herdr server keeps the old
version until `herdr server stop`. Use `install-herdr` rather than
`herdr update`. Servers on kit and cog update through NixOS; client and server
versions only need to be compatible.

Herdr's settings come from the NixOS flake. kit exports their portable part
(`programs.herdr.exportSettings` in `modules/home/default/options/herdr/export.nix`)
to `jon/profile/apps/herdr/config.toml`, Syncthing carries it to the phone,
and `setup.sh` links `~/.config/herdr/config.toml` to it. The export leaves out
custom commands other than plugin actions, such as `herdr-reclaim`, because
they name Nix-store scripts, and it leaves out `ui.sound`. The Alt+hjkl,
Alt+u/i/w, and Alt+Shift+hjkl bindings call the
[edger](https://github.com/suderman/edger) plugin, which `setup.sh` installs
from GitHub and updates with `herdr plugin update --yes`; kit and cog link
their own copy from the flake. Each machine runs the plugin where its panes
run. Change settings in the flake and switch kit, then use the UI's reload
config action or `herdr server reload-config`. Herdr keeps logs, sockets, and
sessions in `config/herdr`, which `.gitignore` excludes.

`setup.sh` saves kit and cog as Herdr machines on their `default` sessions,
skipping any already saved. Saving one only attaches to the server already
running there; if a server is missing or incompatible, Herdr asks before
installing or replacing it, and the default answer is No. Herdr keeps saved
machines outside this repository, in
`~/.local/state/herdr/client/endpoints.json`. Run `herdr`: the sidebar shows
Local, kit, and cog, and `prefix+w` (`Alt+z`, then `w`) moves through
workspaces on every machine.

```sh
herdr machine list              # saved machines and their IDs
herdr machine status            # check each one without prompting
ssh-unlock                      # load the key; Herdr reconnects within a minute
herdr machine add kit --remote-session default
herdr --remote kit              # one-off attach to a single host
```

Background connections need the SSH key in the agent. Herdr runs them with
`BatchMode=yes`, so `ssh-unlock` does not ask for a fingerprint there; the
machine shows `! auth` until the key is back. Run `ssh-unlock`, or any
interactive ssh, to unlock it with a fingerprint, and Herdr reconnects at its
next retry, about every 40 seconds. `herdr machine reconnect` fails on Android
with "unsafe SSH control directory parent", even with the key loaded. Herdr
0.9.5 keeps ssh control sockets in `/tmp/hssh-<uid>` on Linux, and Android's
`/tmp` belongs to the `shell` user.

Upstream does not support Android, so a future release could break this.
Remote clipboard-image paste finds no image on Termux.

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

`sshd`, `ssh-agent`, `mpd`, `mpd-url`, and `syncthing` run under
`termux-services`. `crond`, `mpdscribble`, and `hermes` are intentionally
disabled.

`ssh-agent` is the service the `openssh` package ships. Its socket is
`$PREFIX/var/run/ssh-agent.socket`. Outgoing ssh adds keys to it for an hour.

`setup.sh` links `~/.ssh/config` to `config/ssh/config`, moving a hand-written
file aside to `~/.ssh/config.before-managed` the first time. Termux ssh, Git,
and the Emacs APK's TRAMP all read it:

```
Match exec "%d/bin/ssh-hosts"
Match all
Include /data/data/com.termux/files/home/.ssh/config.local
Include /data/data/com.termux/files/home/.ssh/hosts.conf

Host *
  IdentityAgent /data/data/com.termux/files/usr/var/run/ssh-agent.socket
  AddKeysToAgent 1h
  StrictHostKeyChecking accept-new
  LogLevel ERROR

Match exec "%d/bin/ssh-unlock"
```

The defaults come last because ssh keeps the first value it reads.

The Host blocks come from the NixOS flake. On kit, Home Manager's
`programs.ssh.exportHosts` writes the flake's generated Host blocks, without
its `Host *` defaults, to `~/profile/apps/ssh/hosts.conf`, and copies kit's
private `~/.ssh/config.local` beside it. Syncthing carries both to
`/storage/emulated/0/jon/profile/apps/ssh`. ssh refuses to include files from
shared storage, so `ssh-hosts` copies them into `~/.ssh` with mode 600 whenever
they change, before every connection. Change hosts in the flake or in kit's
`config.local`, not on the phone.

`ssh-unlock` runs before every connection too: it returns at once when the
agent has the key and asks for a fingerprint when it does not, so `ssh kit`,
Git, and TRAMP links unlock the same way. `%d` is ssh's home directory, which
stays Termux's home when Emacs runs ssh. `Include` expands `~` from `$HOME`
instead, which is the APK's own home there, so the includes use full paths.

`ssh-unlock` adds `~/.ssh/id_ed25519` to the agent for an hour after a
fingerprint, and runs any command given after it. Run `ssh-unlock init` once
to store the key's passphrase, encrypted with a secret only the hardware
keystore key `ssh-unlock` can produce. Without a fingerprint match it asks for
the passphrase.

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
