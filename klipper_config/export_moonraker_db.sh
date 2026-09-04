#!/usr/bin/env bash
# Export Moonraker's "fluidd" database namespace (macro groups/colors, layout,
# camera settings, console history, etc) into the klipper_config folder so it
# rides along with the normal git-based config backup. This data lives in
# Moonraker's LMDB database, NOT in printer.cfg, so it would otherwise be
# silently lost on any restore/reflash.
set -e
OUT="$HOME/klipper_config/fluidd_macros_backup.json"
curl -s "http://localhost:7125/server/database/item?namespace=fluidd" | \
  python3 -c "
import json, sys, datetime
data = json.load(sys.stdin)
snapshot = {
    '_note': 'Backup snapshot of the full Fluidd Moonraker database namespace (cameras, layout, macros/categories/colors, console history, etc). Restore by POSTing namespace_value back to /server/database/item with {namespace: \\'fluidd\\', key: <key>, value: <value>} per sub-key, or ask Claude to restore it.',
    'exported_at': datetime.datetime.utcnow().isoformat() + 'Z',
    'namespace_value': data['result']['value'],
}
print(json.dumps(snapshot, indent=2))
" > "$OUT"
echo "Exported fluidd database namespace to $OUT"
