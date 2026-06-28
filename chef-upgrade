#!/usr/bin/env bash
set -e

# Target minimum major version
TARGET_MAJOR=18

# Detect if chef-solo is installed and get version
if command -v chef-solo &> /dev/null; then
  CURRENT_VERSION=$(chef-solo -v 2>/dev/null | awk '/Client:/ {print $NF}')
  MAJOR_VERSION=$(echo "$CURRENT_VERSION" | cut -d. -f1)
else
  CURRENT_VERSION="none"
  MAJOR_VERSION=0
fi

echo "Current Chef/Cinc Client version: $CURRENT_VERSION"

if [ -z "$MAJOR_VERSION" ] || [ "$MAJOR_VERSION" -lt "$TARGET_MAJOR" ]; then
  echo "Upgrade required (installed version is below version $TARGET_MAJOR)."
  echo "Installing Cinc Client version $TARGET_MAJOR..."
  curl -L https://omnitruck.cinc.sh/install.sh | sudo bash -s -- -v "$TARGET_MAJOR"
  echo "Upgrade complete. New version:"
  chef-solo -v
else
  echo "No upgrade needed. Chef/Cinc Client is already at version $CURRENT_VERSION (>= $TARGET_MAJOR)."
fi
