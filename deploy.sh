#!/usr/bin/env bash
set -euo pipefail

cd /srv/homelab
git pull

for f in /srv/homelab/stacks/*/docker-compose.yml; do
  echo "Deploying $f"
  docker compose --env-file /srv/homelab/.env -f "$f" up -d
done