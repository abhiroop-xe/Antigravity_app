#!/bin/bash
set -e

# Configuration
TOOLS_DIR="$(pwd)/tools"
FLUTTER_ROOT="$TOOLS_DIR/flutter"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.5-stable.tar.xz"

echo "=== setup_flutter.sh started ==="

if [ -d "$FLUTTER_ROOT" ]; then
    echo "Flutter directory exists at $FLUTTER_ROOT"
else
    echo "Downloading Flutter SDK..."
    curl -L "$FLUTTER_URL" -o "$TOOLS_DIR/flutter.tar.xz"
    
    echo "Extracting Flutter..."
    tar -xf "$TOOLS_DIR/flutter.tar.xz" -C "$TOOLS_DIR"
    rm "$TOOLS_DIR/flutter.tar.xz"
    echo "Flutter extracted."
fi

# Add flutter to PATH for this script (or next steps)
export PATH="$FLUTTER_ROOT/bin:$PATH"

echo "Configuring Flutter..."
# Disable analytics to avoid prompts
flutter config --no-analytics

# Configure Android SDK location
# Assuming setup_emulator.sh was run and android-sdk is in tools/android-sdk
ANDROID_SDK_ROOT="$TOOLS_DIR/android-sdk"
if [ -d "$ANDROID_SDK_ROOT" ]; then
    echo "Setting Android SDK path to $ANDROID_SDK_ROOT"
    flutter config --android-sdk "$ANDROID_SDK_ROOT"
    
    # Accept licenses (flutter doctor might complain otherwise)
    echo "Accepting Android licenses via flutter..."
    yes | flutter doctor --android-licenses >/dev/null 2>&1 || true
else
    echo "Warning: Android SDK not found at $ANDROID_SDK_ROOT. Run setup_emulator.sh first."
fi

echo "=== Flutter Setup Complete ==="
flutter --version
