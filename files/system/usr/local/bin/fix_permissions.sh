#!/bin/bash
set -e
SHARED_DIR="$HOME/3D_Workstation"
echo "🏭 Initializing Manufacturing Bridge..."
if [ ! -d "$SHARED_DIR" ]; then
    mkdir -p "$SHARED_DIR"
fi
echo "🛡️ Applying SELinux Context (svirt_sandbox_file_t)..."
chcon -R -t svirt_sandbox_file_t "$SHARED_DIR"
echo "✅ Host Bridge Ready."
