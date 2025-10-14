#!/bin/bash
set -e

PI_HOST=williatf@pi4.local             # or your Pi hostname/IP
PI_PATH=/home/williatf/bin/rpitelecine_v4     # project path on Pi
BRANCH=$(git rev-parse --abbrev-ref HEAD)

echo "🚀 Deploying branch '$BRANCH' to $PI_HOST..."

# Push current branch
git push origin "$BRANCH"

# Sync files to Pi
ssh "$PI_HOST" "mkdir -p $PI_PATH"
rsync -avz --exclude '.git' --exclude '.github' . "$PI_HOST:$PI_PATH"

# Update the Pi’s branch and restart
ssh "$PI_HOST" << EOF
  cd $PI_PATH
  git fetch origin "$BRANCH"
  git checkout "$BRANCH" || git checkout -b "$BRANCH"
  git pull origin "$BRANCH"
  ./restart.sh || true
EOF

echo "✅ Deployment complete for branch '$BRANCH'"
