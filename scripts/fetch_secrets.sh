#!/usr/bin/env bash
set -euo pipefail

OUT_FILE="/srv/homelab/secrets-export.env"

if [[ -z "${ALL_SECRETS_JSON:-}" ]]; then
  echo "ALL_SECRETS_JSON is not set"
  exit 1
fi

echo "Exporting secrets to $OUT_FILE"

export ALL_SECRETS_JSON OUT_FILE

python3 <<'PY'
import json
import os
from pathlib import Path

out = Path(os.environ["OUT_FILE"])
secrets = json.loads(os.environ["ALL_SECRETS_JSON"])

def quote_env(value):
    value = str(value)
    value = value.replace("\\", "\\\\")
    value = value.replace("\n", "\\n")
    value = value.replace('"', '\\"')
    return f'"{value}"'

lines = []

for key in sorted(secrets):
    value = secrets[key]

    if value is None or value == "":
        continue

    lines.append(f"{key}={quote_env(value)}")

out.write_text("\n".join(lines) + "\n", encoding="utf-8")
PY

chmod 600 "$OUT_FILE"

echo
echo "Done."
echo "Secrets written to:"
echo "  $OUT_FILE"
echo
echo "View with:"
echo "  cat $OUT_FILE"