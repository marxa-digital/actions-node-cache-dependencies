#!/bin/bash
set -e

WORKING_DIR="${WORKING_DIR:-.}"
echo "Validating dependency installation status in $WORKING_DIR..."

# Check if node_modules exists and contains packages
if [ -d "$WORKING_DIR/node_modules" ] && [ "$(ls -A "$WORKING_DIR/node_modules" 2>/dev/null)" ]; then
  # Additional validation: check if package.json dependencies are installed
  if [ -f "$WORKING_DIR/package.json" ]; then
    REQUIRED_DEPS=$(node -e "console.log(Object.keys(require('./$WORKING_DIR/package.json').dependencies || {}).join(' '))")
    MISSING=0
    
    for DEP in $REQUIRED_DEPS; do
      if [ ! -d "$WORKING_DIR/node_modules/$DEP" ]; then
        echo "::warning::Missing dependency: $DEP"
        MISSING=$((MISSING + 1))
      fi
    done
    
    if [ $MISSING -gt 0 ]; then
      echo "::warning::$MISSING dependencies appear to be missing. Installation may be incomplete."
    fi
  fi
  
  # Determine success source and set output
  if [ "$CACHE_HIT" == "true" ]; then
    echo "✅ Dependencies successfully restored from cache!"
    echo "source=cache" >> $GITHUB_OUTPUT
  else
    echo "✅ Dependencies successfully installed from npm!"
    echo "source=install" >> $GITHUB_OUTPUT
  fi
  
  echo "success=true" >> $GITHUB_OUTPUT
  echo "::notice::Node.js dependencies are ready to use"
else
  echo "❌ Dependencies not available. Installation or cache restoration failed."
  echo "success=false" >> $GITHUB_OUTPUT
  echo "source=none" >> $GITHUB_OUTPUT
  echo "::error::Failed to prepare Node.js dependencies"
  exit 1
fi