#!/usr/bin/bash
set -ouex pipefail

echo "🤖 Installing AI Tools via Direct Download..."

# 1. Install uv (Python Tooling)
curl -LsSf https://astral.sh/uv/install.sh | sh
# Move from temp to system bin
mv /root/.cargo/bin/uv /usr/bin/uv
mv /root/.cargo/bin/uvx /usr/bin/uvx

# 2. Install Ramalama (via Pip is safest for system-wide)
# We use the system python to ensure it's always there
pip install ramalama

# 3. Install AIChat (Binary)
# Fetches latest linux-x86_64 release
curl -L https://github.com/sigoden/aichat/releases/latest/download/aichat-x86_64-unknown-linux-musl.tar.gz | tar -xz -C /usr/bin/ aichat

# 4. Install Whisper.cpp (Building from source is risky, skipping for now)
# Note: Whisper is usually better run inside a container or via Ramalama

echo "✅ AI Tools Installed!"
