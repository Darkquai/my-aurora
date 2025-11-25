#!/bin/bash
set -e
echo "📦 [Project] Checking Base Dev Tools..."
sudo dnf update -y
sudo dnf install -y gcc gcc-c++ make cmake git automake autoconf libtool
sudo dnf install -y python3-devel openssl-devel libffi-devel fzf ripgrep bat jq opentofu

if ! [ -f /usr/bin/terraform ]; then
    sudo ln -s /usr/bin/tofu /usr/bin/terraform
fi

echo "🐍 [Project] Checking UV..."
mkdir -p ~/.local/bin
curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR="$HOME/.local/bin" INSTALLER_NO_MODIFY_PATH=1 sh
