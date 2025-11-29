#!/bin/bash
set -e
echo "🍺 Installing Homebrew System..."

# 1. Install Prerequisites
rpm-ostree install -y git curl procps-ng

# 2. Pre-create the directory to bypass root check issues
mkdir -p /home/linuxbrew/.linuxbrew
chown -R $(id -u):$(id -g) /home/linuxbrew

# 3. Install Homebrew (Unattended)
# We use 'yes' to accept prompts and run as the current user (root)
# CI=1 suppresses some interactive checks
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

# 8. Fix Permissions for the future user (UID 1000)
echo "🔒 Setting permissions for future user..."
chown -R 1000:1000 /home/linuxbrew

echo "✅ Homebrew setup complete."
