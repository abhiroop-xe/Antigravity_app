#!/bin/bash
set -e

# Configuration
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOLS_DIR="$DIR/tools"
JDK_DIR="$TOOLS_DIR/jdk"
ANDROID_SDK_ROOT="$TOOLS_DIR/android-sdk"
FLUTTER_ROOT="$TOOLS_DIR/flutter"

# Set Environment
export JAVA_HOME="$JDK_DIR"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
# Prepend to path to ensure local tools are used
export PATH="$FLUTTER_ROOT/bin:$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

echo "Checking environment..."
echo "Using Flutter from: $(which flutter)"
echo "Using Android SDK at: $ANDROID_SDK_ROOT"

echo "Checking connected devices..."
flutter devices

echo "Running app on Android Emulator..."
# Use -d to specify device if needed (emulator-5554 usually)
flutter run -d emulator-5554
