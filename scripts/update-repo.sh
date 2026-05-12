#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-/srv/homelab-repo}"
BRANCH="${BRANCH:-main}"
SYNC_SCRIPT="${SYNC_SCRIPT:-$REPO_DIR/scripts/sync-runtime.sh}"

echo "Updating repo..."
echo "Repo:   $REPO_DIR"
echo "Branch: $BRANCH"

git -C "$REPO_DIR" config --global --add safe.directory "$REPO_DIR"
git -C "$REPO_DIR" fetch origin "$BRANCH"
git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"

chmod +x "$SYNC_SCRIPT"
"$SYNC_SCRIPT"