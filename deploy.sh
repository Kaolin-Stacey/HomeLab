#!/usr/bin/env bash
set -euo pipefail

cd /srv/homelab
git pull

for stack_dir in /srv/homelab/stacks/*; do
  compose="$stack_dir/docker-compose.yml"
  [ -f "$compose" ] || continue

  echo "Deploying $compose"

  # Base env (global)
  args=(--env-file /srv/homelab/.env)

  # Optional stack override env
  if [ -f "$stack_dir/.env" ]; then
    args+=(--env-file "$stack_dir/.env")
  fi

  docker compose "${args[@]}" -f "$compose" up -d
done