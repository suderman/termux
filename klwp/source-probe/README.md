# KLWP native-source probe

This experiment tests direct editing of KLWP's exported preset format. It uses
KLWP's own export as the reference. There is no layout generator or alternate
schema.

## Contents

- `gui-reference/KLWP_Source_Probe_GUI.klwp` is the untouched GUI export.
- `gui-reference/preset.pretty.json` is its readable `preset.json`.
- `source/` is the editable, unpacked preset. KLWP accepted this source after two
  workstation edits and repacks.
- `build/` contains the round-trip artifacts.

The reference is a ZIP archive with `preset.json`, portrait and landscape
thumbnails, and `fonts/Roboto-Regular.ttf`. Its root has one `TEXT` global named
`agenda`, one text item, and one flow. The flow selects
`Kustom/data/klwp-probe.json` through Android's document provider, evaluates
`$wg(#last,json,.probe)$`, and stores the result in `agenda`.

No shape, explicit colour, touch action, or explicit text dimensions exist in
this small reference. Preset dimensions are 540 by 1205 with a four-screen
horizontal count. Use fresh GUI exports as examples before source-editing
untested module types.

The thumbnails remain the original GUI-export previews and show `GEM JSON ONE`.
They are intentionally stale test fixtures, not proof of the current source
render. Real home-screen screenshots provide render evidence.

## Build

Run:

```sh
./klwp/source-probe/build.sh
```

This validates `source/preset.json` as JSON and packs the native files into
`build/KLWP_Source_Probe.klwp`. ZIP timestamps and permissions are fixed so the
same source produces the same archive bytes.

## Load on gem

Push the archive to a staging directory inside the existing Kustom document
grant:

```sh
scp klwp/source-probe/build/KLWP_Source_Probe.klwp \
  gem:/storage/emulated/0/Kustom/import/KLWP_Source_Probe.klwp
```

Open KLWP's native import activity with a document-provider URI:

```sh
adb shell am start \
  -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -t application/octet-stream \
  --grant-read-uri-permission \
  -d 'content://com.android.externalstorage.documents/document/primary%3AKustom%2Fimport%2FKLWP_Source_Probe.klwp' \
  -n org.kustom.wallpaper/org.kustom.app.PresetImportActivity
```

Confirm Import, load the imported card from KLWP's Library, then save it in the
editor. Return to KISS for the real render check.

Direct `file://` import fails with `EACCES`. Direct `kfile://` loading does not
resolve presets from local external storage on KLWP 3.82b621115. Do not force-stop
KLWP as part of this loop because Android unsets the live wallpaper service.
