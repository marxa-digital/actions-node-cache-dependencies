#!/bin/bash

# Input parameters
TARGET_BRANCH="$1"
WORKING_DIR="${2:-.}" # Default to current directory if not provided

# Ensure working directory exists
if [ ! -d "$WORKING_DIR" ]; then
  echo "::error::Working directory '$WORKING_DIR' does not exist!"
  exit 2
fi

# Go to working directory
cd "$WORKING_DIR" || { echo "::error::Failed to change to directory $WORKING_DIR"; exit 2; }

# Check if package.json exists
if [ ! -f "package.json" ]; then
  echo "::error::No package.json found in '$WORKING_DIR'!"
  exit 2
fi

# Ensure we have up-to-date remote information
git fetch --prune

if [ -z "$TARGET_BRANCH" ]; then
  # Get default branch from remote HEAD
  DEFAULT_BRANCH=$(git rev-parse --abbrev-ref origin/HEAD | sed 's#origin/##')
  TARGET_BRANCH=$DEFAULT_BRANCH
  echo "No target branch provided, using repository default branch: $TARGET_BRANCH"
fi

echo "Checking for changes in package files against branch: $TARGET_BRANCH"
echo "Working directory: $WORKING_DIR"

# Check both package.json and package-lock.json for changes
if git diff --quiet $TARGET_BRANCH -- package.json package-lock.json 2>/dev/null; then
  echo "changes=false"
  echo "✅ No changes detected in package files"
  exit 0
else
  echo "changes=true"
  echo "⚠️ Changes detected in package files"
  exit 1
fi