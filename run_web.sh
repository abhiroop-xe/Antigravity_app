#!/bin/bash
set -e

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOLS_DIR="$DIR/tools"
FLUTTER_ROOT="$TOOLS_DIR/flutter"

# Set Environment
# Prepend to path to ensure local tools are used
export PATH="$FLUTTER_ROOT/bin:$PATH"

echo "Checking environment..."
echo "Using Flutter from: $(which flutter)"

echo "Running app on Chrome..."
flutter run -d web-server --web-hostname localhost --web-port 8080
