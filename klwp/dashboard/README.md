# Gem dashboard

This is the editable native KLWP preset for the Pixel 10 Pro. It was built from
KLWP's exported `source-probe` preset, not from an independent preset schema.
`source/preset.json` is the source of truth. Seven document flows read
`/storage/emulated/0/Kustom/data/org-agenda/snapshot.json` through KLWP's
existing Android document grant. The dedicated directory matters because
Kustom's document action offers a contains-name filter, not exact matching. The Emacs exporter in `~/.config/emacs/lisp/suderman-org-klwp.el`
produces that file; no personal Org data is stored in this repository.
`org-agenda.schema.json` documents the version-one interface.

Run `./klwp/dashboard/build.sh` to validate and pack the source into
`build/Gem_Dashboard.klwp`. Import it through KLWP's native document-provider
intent, load the Library card, and save in the editor. The earlier
`source-probe/README.md` records the tested import command and UI steps.

The current source is Gem Dashboard V8. It has the date, weather, real Org next
item and counters, TODO/NOTE capture, Emacs, Grove agenda, contextual media,
and active-notification indicators. V8 keeps V6's visible geometry but replaces
its flat root-positioned text modules with one local vertical dashboard stack.
Header and action rows are horizontal stacks. Each interactive region is an
overlap group with a transparent rectangle that defines its bounds and owns its
touch action. TODO, NOTE, EMACS, and AGENDA are four neighboring cells with no
dead gap between cells or rows.

Only the Dashboard group uses root-relative placement. Text leaves use small
local offsets inside their groups, so selecting a control shows its useful local
rectangle instead of an origin-to-label box. KLWP's root Layer scale changes the
editor preview but did not change the KISS render on this build, even after
saving and restarting KISS. Keep explicit group geometry as the source of layout
size.

The Emacs exporter sends `org.kustom.action.SEND_VAR` broadcasts after each
successful snapshot. Broadcast values are authoritative for live refresh. The
seven 15-minute document flows remain as cold-load fallback because Kustom's
cron and repeated reads are not reliable freshness signals. The generated-date
guard labels old data instead of showing stale counts.

Whitespace taps inside TODO, NOTE, Emacs, Agenda, weather, agenda summary, and
media opened their intended targets on gem. Direct touch still distinguishes taps from
KISS swipes: a swipe beginning inside the TODO cell opened Termux without firing
TODO, the opposite swipe opened Vanadium, and long-press opened Phone. Media
display passed with PipePipe, AntennaPod, and Symfonium; tapping it opens the
current player. Playback controls were removed because their taps also opened
KISS history. Notification values are active-notification counts, not unread
counts.

There is no Event button until Grove has an Event capture template. The two
thumbnails are copied from the original source probe. They are stale and are not
render evidence. Use screenshots from the real KISS home screen. DClock2 remains
backed up separately in the Org task materials and on the phone.
