#!/bin/bash
set -e

# Configuration
TOOLS_DIR="$(pwd)/tools"
JDK_DIR="$TOOLS_DIR/jdk"
ANDROID_SDK_ROOT="$TOOLS_DIR/android-sdk"
# Using a specific older version of commandlinetools to be safe, or latest
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"
# Microsoft Build of OpenJDK 17
JDK_URL="https://aka.ms/download-jdk/microsoft-jdk-17-linux-x64.tar.gz"

mkdir -p "$TOOLS_DIR"

echo "=== setup_emulator.sh started ==="

# 1. Setup JDK
if [ -d "$JDK_DIR" ]; then
    echo "JDK directory exists, assuming it is valid."
else
    echo "Downloading JDK 17..."
    # We use -L to follow redirects
    if curl -L "$JDK_URL" -o "$TOOLS_DIR/jdk.tar.gz"; then
        echo "Download successful."
    else
        echo "Download failed."
        exit 1
    fi
    
    mkdir -p "$JDK_DIR"
    echo "Extracting JDK..."
    tar -xzf "$TOOLS_DIR/jdk.tar.gz" -C "$JDK_DIR" --strip-components=1
    rm "$TOOLS_DIR/jdk.tar.gz"
fi

# Set JAVA_HOME and PATH for this session
export JAVA_HOME="$JDK_DIR"
export PATH="$JAVA_HOME/bin:$PATH"

echo "Java version:"
java -version

# 2. Setup Android Command Line Tools
CMDLINE_DIR="$ANDROID_SDK_ROOT/cmdline-tools"

if [ -f "$CMDLINE_DIR/latest/bin/sdkmanager" ]; then
    echo "sdkmanager exists, skipping download."
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
    export PATH="$CMDLINE_DIR/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
else
    echo "Downloading Android Command Line Tools..."
    curl -o "$TOOLS_DIR/cmdtools.zip" "$CMDLINE_TOOLS_URL"
    
    mkdir -p "$CMDLINE_DIR"
    
    # Use python to unzip if unzip is not available, or just use unzip
    if command -v unzip >/dev/null 2>&1; then
        unzip -q "$TOOLS_DIR/cmdtools.zip" -d "$CMDLINE_DIR"
    else
        echo "unzip not found, using python..."
        python3 -c "import zipfile, sys; zipfile.ZipFile(sys.argv[1], 'r').extractall(sys.argv[2])" "$TOOLS_DIR/cmdtools.zip" "$CMDLINE_DIR"
    fi
    
    # Restructing: cmdline-tools/cmdline-tools -> cmdline-tools/latest
    # The zip usually contains a top-level folder 'cmdline-tools'
    if [ -d "$CMDLINE_DIR/cmdline-tools" ]; then
        mv "$CMDLINE_DIR/cmdline-tools" "$CMDLINE_DIR/latest"
    elif [ -d "$CMDLINE_DIR/tools" ]; then
         mv "$CMDLINE_DIR/tools" "$CMDLINE_DIR/latest"
    else
        # Sometimes it unzips directly without a wrapper if we aren't careful, 
        # but standard google zip has a wrapper.
        # If it's already correct (rare), do nothing.
        echo "Check directory structure..."
        ls -F "$CMDLINE_DIR"
    fi
    
    rm "$TOOLS_DIR/cmdtools.zip"
    
    export ANDROID_HOME="$ANDROID_SDK_ROOT"
    export PATH="$CMDLINE_DIR/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
fi

echo "Using sdkmanager at: $(which sdkmanager)"

# 3. Accept Licenses
echo "Accepting licenses..."
# Verify yes is available
if ! command -v yes >/dev/null 2>&1; then
    echo "Error: 'yes' command not found."
    exit 1
fi

yes | sdkmanager --licenses > /dev/null 2>&1 || true

# 4. Install Components
echo "Installing Android Emulator components..."
echo "This might take a few minutes..."
# Use --verbose to see progress if needed, but might clutter logs.
sdkmanager "platform-tools" "platforms;android-34" "emulator" "system-images;android-34;google_apis;x86_64"

# 5. Create AVD
echo "Creating AVD 'test_emulator'..."
# Check if AVD exists
if avdmanager list avd | grep -q "test_emulator"; then
    echo "AVD 'test_emulator' already exists."
else
    echo "no" | avdmanager create avd -n "test_emulator" -k "system-images;android-34;google_apis;x86_64" --force
    echo "AVD created."
fi

echo "=== Setup Complete ==="
echo "To run the emulator:"
echo "export JAVA_HOME=$JDK_DIR"
echo "export ANDROID_HOME=$ANDROID_SDK_ROOT"
echo "export PATH=\$JAVA_HOME/bin:\$ANDROID_HOME/cmdline-tools/latest/bin:\$ANDROID_HOME/platform-tools:\$ANDROID_HOME/emulator:\$PATH"
echo "emulator -avd test_emulator"
