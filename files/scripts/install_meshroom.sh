#!/bin/bash
set -eux pipefail

echo "📸 Installing Meshroom..."

# Define install directories
INSTALL_DIR="/opt/Meshroom"
ALICEVISION_DIR="$INSTALL_DIR/AliceVision"
MESHROOM_DIR="$INSTALL_DIR/Meshroom"
TARGET_UID=1000

mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# --- 1. Install AliceVision prebuilt binaries ---
# We need to determine the correct release URL/filename for the current build OS (e.g., Fedora 40/41)
# The user needs to verify the latest release URL/OS version compatibility from:
# github.com

# Placeholder URL - User must verify the correct Linux package release URL!
# Example using a potential Fedora-compatible binary:
AV_URL="github.com/download/v2.5.0/AliceVision-2.5.0-linux.tar.gz"
AV_TAR="AliceVision-2.5.0-linux.tar.gz"

curl -fsSL "$AV_URL" -o "$AV_TAR"
tar -xzvf "$AV_TAR"
rm "$AV_TAR"

# The extracted folder is typically named 'AliceVision-2.5.0-linux'
mv AliceVision-*/ "$ALICEVISION_DIR"


# --- 2. Install Meshroom source code (UI) ---
git clone --recursive https://github.com/alicevision/Meshroom.git "$MESHROOM_DIR"
cd "$MESHROOM_DIR"

# Install Python requirements system-wide within the build environment
pip install -r requirements.txt

# --- 3. Configure Environment Variables (System-wide via environment.d) ---

ENV_DIR="/etc/profile.d/meshroom_env.sh"
touch "$ENV_DIR"
echo "export ALICEVISION_ROOT=$ALICEVISION_DIR" >> "$ENV_DIR"
echo "export MESHROOM_NODES_PATH=$ALICEVISION_DIR/share/meshroom" >> "$ENV_DIR"
echo "export MESHROOM_PIPELINE_TEMPLATES_PATH=$ALICEVISION_DIR/share/meshroom" >> "$ENV_DIR"
# Add AliceVision binaries to PATH
echo "export PATH=\$PATH:$ALICEVISION_DIR/bin" >> "$ENV_DIR"
echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$ALICEVISION_DIR/lib" >> "$ENV_DIR"
# Required for Qt/PySide to find plugins
echo "export QML2_IMPORT_PATH=\$QML2_IMPORT_PATH:$ALICEVISION_DIR/qml" >> "$ENV_DIR"
echo "export QT_PLUGIN_PATH=\$QT_PLUGIN_PATH:$ALICEVISION_DIR/plugins" >> "$ENV_DIR"


# --- 4. Fix Permissions for the installed files ---
# All files installed by root must be owned by the final user (UID 1000)
chown -R $TARGET_UID:$TARGET_UID "$INSTALL_DIR"

echo "✅ Meshroom Installation complete. Environment variables configured in $ENV_DIR"
