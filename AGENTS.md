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
