#!/usr/bin/bash
set -ouex pipefail

echo "🤖 Installing AI Tools via Direct Download..."

# --- 1. Install uv (Python Manager) ---
curl -LsSf https://astral.sh/uv/install.sh | sh
# Move to system bin so everyone can use it
mv /root/.cargo/bin/uv /usr/bin/uv
mv /root/.cargo/bin/uvx /usr/bin/uvx

# --- 2. Install Ramalama (via Pip is safest system-wide) ---
# This ensures it uses the system python and is available immediately
pip install ramalama

# --- 3. Install AIChat (Binary Download) ---
curl -L https://github.com/sigoden/aichat/releases/latest/download/aichat-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/bin/ aichat

# --- 4. Install Syft & YQ (Container Tools) ---
curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b /usr/bin
wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && chmod +x /usr/bin/yq

echo "✅ AI Tools Installed!"
