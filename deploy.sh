#!/usr/bin/env bash
set -e

cd /srv/homelab

echo "Pulling latest from Git..."
git pull

echo "Deploying each stack..."

for stack in stacks/*; do
  if [ -f "$stack/docker-compose.yml" ]; then
    echo "Deploying $stack..."
    docker compose -f "$stack/docker-compose.yml" up -d
  fi
done

echo "Done."