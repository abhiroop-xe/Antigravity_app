#!/bin/bash

# Configuration
# Resolves the directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TOOLS_DIR="$DIR/tools"
JDK_DIR="$TOOLS_DIR/jdk"
ANDROID_SDK_ROOT="$TOOLS_DIR/android-sdk"

# Set Environment
export JAVA_HOME="$JDK_DIR"
export ANDROID_HOME="$ANDROID_SDK_ROOT"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

# Check if AVD exists
if ! avdmanager list avd | grep -q "test_emulator"; then
    echo "Error: AVD 'test_emulator' not found. Please run setup_emulator.sh first."
    exit 1
fi

echo "Starting emulator 'test_emulator'..."
emulator -avd test_emulator "$@"
