#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="/srv/homelab"
STACKS_DIR="$ROOT_DIR/stacks"

STACK="${1:-}"
ACTION="${2:-up}"
ALLOW_CORE="${ALLOW_CORE:-false}

if [[ -z "$STACK" ]]; then
  echo "Usage: $0 <stack-path> <up|down|pull|restart|logs>"
  exit 1
fi

STACK_DIR="$STACKS_DIR/$STACK"

if [[ "$STACK" == core/* && "$ALLOW_CORE" != "true" ]]; then
  echo "Refusing to modify core stack without ALLOW_CORE=true"
  exit 1
fi

if [[ ! -f "$STACK_DIR/docker-compose.yml" && ! -f "$STACK_DIR/compose.yml" ]]; then
  echo "No compose file found for stack: $STACK"
  exit 1
fi

if [[ -z "${ALL_SECRETS_JSON:-}" ]]; then
  echo "ALL_SECRETS_JSON is not set"
  exit 1
fi

export STACK_DIR ACTION ALL_SECRETS_JSON

python3 <<'PY'
import json
import os
import re
import subprocess
from pathlib import Path

stack_dir = Path(os.environ["STACK_DIR"])
action = os.environ["ACTION"]
all_secrets = json.loads(os.environ["ALL_SECRETS_JSON"])

compose_file = stack_dir / "docker-compose.yml"
if not compose_file.exists():
    compose_file = stack_dir / "compose.yml"

pattern = re.compile(r"\$\{([A-Za-z_][A-Za-z0-9_]*)(?::-[^}]*)?\}")
needed = set(pattern.findall(compose_file.read_text(encoding="utf-8")))

env = os.environ.copy()

print("Variables injected:")
for name in sorted(needed):
    if name in all_secrets and all_secrets[name] != "":
        env[name] = str(all_secrets[name])
        print(f" - {name}")
    elif name in env and env[name] != "":
        print(f" - {name} already present")
    else:
        raise SystemExit(f"Missing variable: {name}")

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