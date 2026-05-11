#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/srv/homelab-repo}"
DEPLOY_DIR="${DEPLOY_DIR:-/srv/homelab}"

echo "Syncing repo to runtime..."
echo "Repo:   $REPO_DIR"
echo "Deploy: $DEPLOY_DIR"

sudo mkdir -p "$DEPLOY_DIR"

sudo rsync -av --delete \
  --exclude ".git" \
  --exclude ".github" \
  "$REPO_DIR/" "$DEPLOY_DIR/"

sudo chown -R github-runner:github-runner "$DEPLOY_DIR"
sudo chmod +x "$DEPLOY_DIR"/scripts/*.sh

echo "Sync complete."