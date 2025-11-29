#!/bin/bash
set -eux pipefail

echo "🍺 Setting up and Installing Homebrew Packages (as root)..."

# 1. Install necessary dependencies for Homebrew
# Since the script runs as root, commands are run directly (no sudo needed)
rpm-ostree install -y curl git make procps findutils

# Define the future user's UID
TARGET_UID=1000

# 2. Download and run the Homebrew installation script using a temporary file
HB_SCRIPT="/tmp/install_homebrew.sh"
# THIS IS THE CORRECT, FULL URL:
curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh -o "$HB_SCRIPT"

# 3. Run the installation script (still as root, but non-interactive)
NONINTERACTIVE=1 /bin/bash "$HB_SCRIPT"
rm "$HB_SCRIPT" # Clean up the temp file

# 4. Fix permissions: Change ownership from root (0) to the future user (1000)
# Homebrew installs to /home/linuxbrew/.linuxbrew
chown -R $TARGET_UID:$TARGET_UID /home/linuxbrew

# 5. The rest of the script needs to run the 'brew' commands, which requires
# setting up the environment variables that Homebrew normally handles.
export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

# Add Taps (Repositories)
brew tap charmbracelet/tap
brew tap gptscript-ai/tap
brew tap blockprotocol/tap

# Install Core Tools & AI Suite
brew install uv ripgrep bat eza fzf zoxide walk syft yq gum aichat block-goose-cli gemini-cli mods ramalama llm opencode qwen-code whisper-cpp clio crush

brew cleanup
echo "✅ Homebrew setup complete and permissions set for future user."
