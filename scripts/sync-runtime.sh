#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/srv/homelab-repo}"
DEPLOY_DIR="${DEPLOY_DIR:-/srv/homelab}"

mkdir -p "$DEPLOY_DIR"

rsync -av --delete \
  --exclude ".git" \
  --exclude ".github" \
  "$REPO_DIR/" "$DEPLOY_DIR/"

chmod +x "$DEPLOY_DIR"/scripts/*.sh