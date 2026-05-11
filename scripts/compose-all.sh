#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/srv/homelab"
STACKS_DIR="$ROOT_DIR/stacks"
ACTION="${1:-up}"

find "$STACKS_DIR" -name docker-compose.yml | sort | while read -r compose_file; do
  stack_dir="$(dirname "$compose_file")"
  stack="${stack_dir#"$STACKS_DIR/"}"

  if [[ "$stack" == core/* ]]; then
    echo "Skipping protected core stack: $stack"
    continue
  fi

  "$ROOT_DIR/scripts/compose-stack.sh" "$stack" "$ACTION"
done