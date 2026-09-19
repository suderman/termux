#!/usr/bin/env bash
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_dir="$root/source"
output="$root/build/KLWP_Source_Probe.klwp"

SOURCE_DIR="$source_dir" OUTPUT="$output" python3 - <<'PY'
import json
import os
from pathlib import Path
import zipfile

source = Path(os.environ["SOURCE_DIR"])
output = Path(os.environ["OUTPUT"])
json.loads((source / "preset.json").read_text())
output.parent.mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(output, "w") as archive:
    for path in sorted(source.rglob("*")):
        if path.is_file():
            info = zipfile.ZipInfo(path.relative_to(source).as_posix())
            info.date_time = (1980, 1, 1, 0, 0, 0)
            info.compress_type = zipfile.ZIP_DEFLATED
            info.create_system = 3
            info.external_attr = 0o100644 << 16
            archive.writestr(info, path.read_bytes())
with zipfile.ZipFile(output) as archive:
    if broken := archive.testzip():
        raise SystemExit(f"corrupt archive member: {broken}")
    print(output)
    for name in archive.namelist():
        print(f"  {name}")
PY
