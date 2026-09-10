# Agent notes

- Keep diffs small. Run `git status --short` first and treat existing changes as user-owned.
- This repository is deployed as `~/.termux` on GrapheneOS. The development host reaches the phone with `ssh gem`.
- Do not read, copy, or commit private keys, GitHub tokens, Syncthing credentials, or other files outside this repository.
- Use Termux shebangs under `/data/data/com.termux/files/usr/bin/`. Quote paths and keep Bash-only syntax in scripts using the Bash shebang.
- Run `bash -n` on changed scripts and `git diff --check` before deployment. ShellCheck is not currently installed.
- Markdown daily-note creation is retired. Do not restore job 3 or delete the user's existing notes.
- The Emacs APK owns `/data/data/org.gnu.emacs/files/.config/emacs`; do not modify that repository while maintaining this one.
- Termux Emacs uses the APK-owned config through `~/.config/emacs`. Keep legacy `~/.emacs*` and `~/.emacs.d` paths removed because Emacs prefers them over the XDG config.
- Termux owns the real `~/src` directory. The Emacs app links its `~/src` back to that directory.

## Repository and phone boundaries

- Termux configuration and app data are vital user data. Preserve them unless the user explicitly approves a specific replacement, deletion, or reset.
- Editing tracked files in this repository changes source only. Running `adb`, `scrcpy`, `ssh gem`, deployment commands, or Termux setup scripts can change the live phone.
- Before changing the phone, inspect the current screen or target files and confirm the requested change is still appropriate. Inspect existing Termux files or app data and get explicit approval before overwriting, deleting, or resetting them.
- Change tracked source here first when a phone configuration belongs in this repository. Keep repository changes and live-phone deployment as separate, reviewable steps.
- This workspace controls the user's real Pixel 10 Pro named `gem`, running GrapheneOS. Make only ordinary, reversible phone changes that the user requested. Do not make unrelated changes.
- Do not download or install a Termux APK from an unverified source. Never bypass GrapheneOS protections, Android permissions, lock-screen authentication, biometrics, or physical confirmation prompts.

## Android development shell

- On the development host, allow `.envrc` or run `nix develop` to get `adb`, `scrcpy`, `jq`, and the `android-*` helpers. Raw `adb` must remain available when a helper is not enough.
- ADB is the preferred control channel. Use scrcpy primarily as the user's supervised live view.
- Prefer UI hierarchy inspection, intents, package commands, `adb shell input`, and other Android-side controls over Linux mouse or keyboard automation against the scrcpy window.
- If Android-side controls are unavailable, incomplete, or unreliable, scrcpy GUI interaction is allowed. Inspect the window and phone screen first, account for scaling and orientation, perform one or a few actions, and verify each meaningful action.
- Do not abandon an achievable task only because it requires supervised scrcpy GUI interaction.

## Closed-loop phone operation

Treat phone interaction like computer-use automation, not a deterministic shell script.

1. Run `android-status`. Stop unless it reports exactly one authorized device.
2. Capture the current screen with `android-screenshot`.
3. Run `android-ui` when semantic UI information may help.
4. Choose and perform the smallest sensible action.
5. Capture the screen again and inspect UI XML again when useful.
6. Verify the expected transition before continuing.
7. Repeat one action at a time until complete.
8. Finish with a screenshot and relevant in-app verification.

Never issue an unchecked sequence of taps, swipes, typing, and key presses. Dialogs, keyboards, permission prompts, animations, and changed screens can invalidate later actions.

| Command | Use |
| --- | --- |
| `android-status` | Require one authorized device and print its model, Android version, display size, and orientation. |
| `android-screenshot [PATH]` | Save a PNG, by default at `/tmp/android-control/screen.png`. |
| `android-ui [PATH]` | Save uiautomator XML, by default at `/tmp/android-control/window.xml`. |
| `android-tap X Y` | Tap a display coordinate. |
| `android-swipe X1 Y1 X2 Y2 [DURATION_MS]` | Swipe between coordinates. |
| `android-type TEXT` | Enter one base64-transported, single-line text value. |
| `android-key KEYCODE_BACK` | Send a key event such as `KEYCODE_BACK`, `KEYCODE_HOME`, or `KEYCODE_ENTER`. |
| `android-open PACKAGE` | Launch an installed package's launcher activity. |

- Helpers reject zero, unauthorized, offline, or multiple attached devices. For deliberate multi-device work, use raw `adb -s SERIAL ...`.
- Repository-local captures belong under `android-control/` or in files ending with `.android-control.png` or `.android-control.xml`; Git ignores those paths.
- `android-ui` temporarily creates `/sdcard/window.xml`, copies it to the host, and removes the phone-side file.
- Prefer text, content descriptions, resource IDs, clickable state, and bounds from UI XML over guessed coordinates. Some Tasker custom widgets publish incomplete or misleading XML; use screenshot inspection then.
- Coordinates depend on orientation and display geometry. Recheck after rotation, keyboard changes, display-size changes, split screen, dialogs, overlays, or navigation-mode changes.
- `android-type` handles shell quoting for normal single-line text, but Android `input text` may not handle Unicode, newlines, or some IME behavior. Verify after typing. Do not install a phone-side input app unless the user asks.

## Apps and Tasker

- Vanadium package: `app.vanadium.browser`.
- FairEmail package: `eu.faircode.email`.
- Telegram package: `org.telegram.messenger`. Telegram downloads use app-specific paths such as `Download/Telegram/ciao.mp4`; Tasker's root `File Modified` watches do not receive those changes.
- Tasker package: `net.dinglisch.android.taskerm`. The installed version observed on 2026-09-10 was 6.6.20.
- Tasker has All files access through the `MANAGE_EXTERNAL_STORAGE` app-op and is exempt from battery optimization.
- The Download sweep uses enabled `MovedTo` and `ClosedWrite` File Modified profiles on `Download/` and `Download/Telegram/`. Both run `Drain Downloads`, which moves `%evtprm1` to `jon/inbox` while excluding `.pending-*`, `.crdownload`, `.part`, and `.tmp` paths.
- Keep `Drain Downloads` Collision Handling set to `Run Both Together`. `Abort New Task` drops Vanadium's final `MovedTo` event when it closely follows a temporary-file `ClosedWrite` event.
- Vanadium downloads through `.pending-*` and renames to the final name. FairEmail 1Password attachment saves open Android's document picker in `Download`; the final Save writes the selected filename directly and produces `ClosedWrite`.
- `android-open net.dinglisch.android.taskerm` may resolve to Tasker's Secondary App alias. Use `adb shell am start -n net.dinglisch.android.taskerm/.Tasker` to open Tasker's main UI when that occurs.
- Inspect Tasker before navigating. Add profiles, tasks, contexts, events, actions, variables, conditions, and permissions incrementally, checking each name and value.
- Android Back and Tasker's in-app arrow can behave differently. Observe before choosing one, save where required, and return to the relevant overview to verify the profile exists and is enabled.
- When practical, test Tasker changes with a harmless controlled example. Inspect its run or error state rather than assuming successful creation means successful operation.

## Android permissions

- Normal Android or GrapheneOS configuration dialogs are allowed when clearly required by the request. Never bypass the operating system's protections or intentionally non-automatable confirmations.
- If physical confirmation is required, stop and tell the user exactly what to approve. Inspect the current state and continue after approval rather than restarting.
- Require explicit instruction before uninstalling apps, clearing app data, factory resets, deleting user files, broadly revoking permissions, changing developer or debugging security settings, or changing many unrelated settings.
- The user must manually enable Developer Options and USB debugging, connect USB, unlock or allow the phone when GrapheneOS USB security requires it, and accept the Android RSA prompt. Do not automate these steps.

## Services

- `termux-services` uses `SVDIR=$PREFIX/var/service`. Set it explicitly in scripts because noninteractive SSH does not load the profile hook.
- Service templates in `services/` are the source of truth. `setup.sh` copies them to `$PREFIX/var/service/<name>/run`.
- OpenSSH package upgrades recreate `$PREFIX/var/service/sshd/down`. Boot, job 1, and the Tasker poke must keep calling `sv-enable sshd`.
- Intended enabled services are `sshd`, `mpd`, `mpd-url`, and `syncthing`.
- Keep `crond`, `mpdscribble`, and `hermes` disabled. Android jobs replace cron, mpdscribble is not configured, and Hermes is paused.
- Do not reinstall the Hermes compiler and Node/Rust dependencies until Hermes is intentionally re-enabled.
- Keep boot and job wake locks short-lived. GrapheneOS should allow unrestricted background battery usage for Termux instead of holding a permanent wake lock.

## SSH changes

- SSH listens on all interfaces but must remain public-key-only through `config/ssh/sshd_config.d/termux.conf`.
- Before restarting SSH remotely, run `sshd -t`, keep the current session open, and prove a second `ssh gem` connection works.
- After service changes, check `sv status "$PREFIX/var/service/sshd"`; it must not say `normally down`.

## Deployment

- Change tracked source files here first. Avoid editing generated service copies on the phone without making the matching repository change.
- Deploy only intended files to `~/.termux`, then update affected service copies and state with targeted commands. Do not rerun all of `setup.sh` for a small service edit.
- `termux-update` requires a clean worktree, rebases phone commits onto upstream, and runs the idempotent setup. It never commits or pushes.
- Verify enabled services, their logs under `$PREFIX/var/log/sv/`, and a fresh SSH connection before declaring deployment complete.
