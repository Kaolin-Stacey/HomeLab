#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/srv/homelab-repo}"
BRANCH="${BRANCH:-main}"
SYNC_SCRIPT="${SYNC_SCRIPT:-$REPO_DIR/scripts/sync-runtime.sh}"

echo "Updating repo..."
echo "Repo:   $REPO_DIR"
echo "Branch: $BRANCH"

sudo chown -R github-runner:github-runner "$REPO_DIR"

sudo -u github-runner git -C "$REPO_DIR" config --global --add safe.directory "$REPO_DIR"
sudo -u github-runner git -C "$REPO_DIR" fetch origin "$BRANCH"
sudo -u github-runner git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"

sudo chmod +x "$SYNC_SCRIPT"
"$SYNC_SCRIPT"

echo "Repo update + runtime sync complete."