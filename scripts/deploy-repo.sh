#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/srv/HomeLab}"
BRANCH="${BRANCH:-main}"

EXPORT_SECRETS="${EXPORT_SECRETS:-false}"
SECRETS_OUT="${SECRETS_OUT:-/srv/homelab/secrets-export.env}"

echo "Deploying homelab repo"
echo "Repo:   $REPO_DIR"
echo "Branch: $BRANCH"

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "Not a git repo: $REPO_DIR"
  exit 1
fi

cd "$REPO_DIR"

echo "Fetching latest changes..."
git fetch origin "$BRANCH"

echo "Checking out latest origin/$BRANCH..."
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

echo "Setting script ownership and permissions..."

sudo chown -R github-runner:github-runner "$REPO_DIR/scripts"

sudo find "$REPO_DIR/scripts" \
  -type d \
  -exec chmod 755 {} \;

sudo find "$REPO_DIR/scripts" \
  -type f \
  -name "*.sh" \
  -exec chmod 755 {} \;

if [[ "$EXPORT_SECRETS" == "true" ]]; then
  echo
  echo "Exporting secrets to: $SECRETS_OUT"

  if [[ -z "${ALL_SECRETS_JSON:-}" ]]; then
    echo "ALL_SECRETS_JSON is not set"
    exit 1
  fi

  export ALL_SECRETS_JSON SECRETS_OUT

  python3 <<'PY'
import json
import os
from pathlib import Path

out = Path(os.environ["SECRETS_OUT"])
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

  sudo chmod 600 "$SECRETS_OUT"
  sudo chown github-runner:github-runner "$SECRETS_OUT"

  echo "Secrets exported."
fi

echo
echo "Deploy complete."