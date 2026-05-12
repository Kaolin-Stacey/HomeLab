#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/srv/homelab"
STACKS_DIR="$ROOT_DIR/stacks"

STACK="${1:-}"
ACTION="${2:-up}"

VAULT_NAME="${OP_VAULT_NAME:-HomeLab}"
ITEM_NAME="${OP_ITEM_NAME:-Docker Compose Secrets}"

if [[ -z "$STACK" ]]; then
  echo "Usage: $0 <stack-path> <up|down|restart|pull|logs>"
  exit 1
fi

STACK_DIR="$STACKS_DIR/$STACK"
COMPOSE_FILE="$STACK_DIR/docker-compose.yml"

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "No compose file found: $COMPOSE_FILE"
  exit 1
fi

if [[ "$STACK" == core/* && "${ALLOW_CORE:-false}" != "true" ]]; then
  echo "Refusing to modify core stack without ALLOW_CORE=true"
  exit 1
fi

export STACK_DIR COMPOSE_FILE ACTION VAULT_NAME ITEM_NAME

python3 <<'PY'
import json
import os
import re
import subprocess
from pathlib import Path

compose_file = Path(os.environ["COMPOSE_FILE"])
stack_dir = Path(os.environ["STACK_DIR"])
action = os.environ["ACTION"]
vault = os.environ["VAULT_NAME"]
item = os.environ["ITEM_NAME"]

raw_text = compose_file.read_text(encoding="utf-8")

text = "\n".join(
    line for line in raw_text.splitlines()
    if not line.lstrip().startswith("#")
)
var_pattern = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)(?:(:-|-)([^}]*))?\}")
plain_pattern = re.compile(r"(?<!\$)\$([A-Za-z_][A-Za-z0-9_]*)")

required = set()
optional = set()

for match in var_pattern.finditer(text):
    name = match.group(1)
    default_operator = match.group(2)

    if default_operator:
        optional.add(name)
    else:
        required.add(name)

for name in plain_pattern.findall(text):
    required.add(name)

needed = required | optional

print("Fetching secrets from 1Password...")
result = subprocess.run(
    ["op", "item", "get", item, "--vault", vault, "--format", "json"],
    check=True,
    capture_output=True,
    text=True,
)

data = json.loads(result.stdout)

fields = {}
for field in data.get("fields", []):
    label = field.get("label")
    value = field.get("value")
    if label and value not in (None, ""):
        fields[label] = str(value)

env = os.environ.copy()

print("Variables required:")
for name in sorted(needed):
    if name in env and env[name]:
        print(f" - {name}: existing env")
    elif name in fields:
        env[name] = fields[name]
        print(f" - {name}: 1Password")
    else:
        raise SystemExit(f"Missing required variable: {name}")

base = ["docker", "compose", "-f", str(compose_file)]

commands = {
    "up": base + ["up", "-d"],
    "down": base + ["down"],
    "restart": base + ["restart"],
    "pull": base + ["pull"],
    "logs": base + ["logs", "--tail=200"],
}

if action not in commands:
    raise SystemExit(f"Invalid action: {action}")

subprocess.run(commands[action], cwd=stack_dir, env=env, check=True)
PY