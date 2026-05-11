#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="${REPO_DIR:-$HOME/HomeLab}"
DEPLOY_DIR="${DEPLOY_DIR:-/srv/homelab}"
BRANCH="${BRANCH:-main}"

echo "Deploying homelab repo"
echo "Repo:   $REPO_DIR"
echo "Target: $DEPLOY_DIR"
echo "Branch: $BRANCH"

if [[ ! -d "$REPO_DIR/.git" ]]; then
  echo "Not a git repo: $REPO_DIR"
  exit 1
fi

cd "$REPO_DIR"

echo "Fetching latest changes..."
git fetch origin "$BRANCH"

echo "Checking out latest origin/$BRANCH..."
git checkout "$BRANCH"
git pull --ff-only origin "$BRANCH"

echo "Syncing files to $DEPLOY_DIR..."
sudo mkdir -p "$DEPLOY_DIR"

sudo rsync -av --delete \
  --exclude ".git" \
  --exclude ".github" \
  --exclude ".gitignore" \
  "$REPO_DIR/" "$DEPLOY_DIR/"

echo "Setting script ownership and permissions..."

sudo chown -R github-runner:github-runner "$DEPLOY_DIR/scripts"
sudo find "$DEPLOY_DIR/scripts" -type d -exec chmod 755 {} \;
sudo find "$DEPLOY_DIR/scripts" -type f -name "*.sh" -exec chmod 755 {} \;

echo "Deploy complete."
echo
echo "Next examples:"
echo "  cd $DEPLOY_DIR"
echo "  ALL_SECRETS_JSON='{}' ./scripts/compose-stack.sh media/automation up"
echo "  ./scripts/compose-all.sh up"