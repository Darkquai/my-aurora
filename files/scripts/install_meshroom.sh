#!/bin/bash
set -ouex pipefail

echo "📸 Installing Meshroom (Official Standalone)..."

# 1. Define Variables
# Current Stable Release as of late 2024 (2023.3.0)
MESHROOM_VERSION="2023.3.0"
DOWNLOAD_URL="https://github.com/alicevision/Meshroom/releases/download/v${MESHROOM_VERSION}/Meshroom-${MESHROOM_VERSION}-linux.tar.gz"
INSTALL_DIR="/opt/Meshroom"
BIN_LINK="/usr/bin/meshroom"

# 2. Prepare Directory
mkdir -p "$INSTALL_DIR"

# 3. Download and Extract
# We strip the top level directory so it dumps directly into /opt/Meshroom
echo "⬇️ Downloading from $DOWNLOAD_URL..."
curl -L -C - "$DOWNLOAD_URL" | tar -xz -C "$INSTALL_DIR" --strip-components=1

# 4. Fix Permissions
# Ensure the user (UID 1000) can write to it if the app self-updates or writes caches
chown -R 1000:1000 "$INSTALL_DIR"

# 5. Create Symlink for easy launching
# This allows you to just type 'meshroom' in the terminal
ln -sf "$INSTALL_DIR/meshroom" "$BIN_LINK"

# 6. Create Desktop Entry (So it shows up in your App Menu)
mkdir -p /usr/share/applications
cat <<EOF > /usr/share/applications/meshroom.desktop
[Desktop Entry]
Type=Application
Name=Meshroom
Comment=3D Reconstruction Software
Icon=$INSTALL_DIR/meshroom.png
Exec=$INSTALL_DIR/meshroom
Terminal=false
Categories=Graphics;3DGraphics;
EOF

echo "✅ Meshroom Installed to $INSTALL_DIR"
