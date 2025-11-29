#!/bin/bash
set -e
echo "🍺 Installing Homebrew System..."

# 1. Install Prerequisites
rpm-ostree install -y git curl procps-ng

# 2. Pre-create the directory (Atomic Safe Method)
# We create it in /var/home because /home is a read-only symlink
mkdir -p /var/home/linuxbrew/.linuxbrew
# Ensure the symlink path works (in case the installer uses it)
if [ ! -d "/home/linuxbrew" ]; then
    ln -s /var/home/linuxbrew /home/linuxbrew
fi

chown -R $(id -u):$(id -g) /var/home/linuxbrew

# 3. Install Homebrew (Unattended)
CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 4. Configure Environment
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 5. Tap Repositories
echo "🔌 Tapping Repositories..."
brew tap charmbracelet/tap
brew tap gptscript-ai/tap
brew tap blockprotocol/tap

# 6. Install Packages
echo "⬇️  Installing Tools..."
brew install uv ripgrep bat eza fzf zoxide walk syft yq \
    gum aichat block-goose-cli gemini-cli mods ramalama llm \
    opencode qwen-code whisper-cpp clio crush

# 7. Cleanup
brew cleanup

# 8. Fix Permissions for UID 1000
echo "🔒 Setting permissions for future user..."
chown -R 1000:1000 /var/home/linuxbrew

echo "✅ Homebrew setup complete."
