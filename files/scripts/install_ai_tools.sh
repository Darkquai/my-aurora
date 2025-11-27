#!/usr/bin/bash
set -ouex pipefail

echo "🤖 Installing AI Tools via Direct Download..."

# 1. Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh
mv /root/.cargo/bin/uv /usr/bin/uv
mv /root/.cargo/bin/uvx /usr/bin/uvx

# 2. Install Ramalama
pip install ramalama

# 3. Install AIChat
curl -L https://github.com/sigoden/aichat/releases/latest/download/aichat-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/bin/ aichat

# 4. Install Syft & YQ
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/bin
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

# 5. Install Charmbracelet Tools (Mods, Gum, Glow) manually
# Because Fedora 43 COPR is broken.
rpm -ivh https://github.com/charmbracelet/mods/releases/download/v1.7.0/mods_1.7.0_linux_amd64.rpm
rpm -ivh https://github.com/charmbracelet/gum/releases/download/v0.14.5/gum_0.14.5_linux_amd64.rpm
rpm -ivh https://github.com/charmbracelet/glow/releases/download/v2.0.0/glow_2.0.0_linux_amd64.rpm

echo "✅ AI Tools Installed!"
