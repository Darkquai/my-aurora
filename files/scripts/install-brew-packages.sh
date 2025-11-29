#!/bin/bash
set -eux pipefail

echo "🍺 Setting up and Installing Homebrew Packages..."

# 1. Install necessary dependencies for Homebrew
rpm-ostree install -y curl git make procps findutils

# 2. Run the Homebrew installation script (installs to /home/linuxbrew/.linuxbrew)
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL raw.githubusercontent.com)"

# 3. Initialize Homebrew environment
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# 4. Add Taps (Repositories)
brew tap charmbracelet/tap
brew tap gptscript-ai/tap
brew tap blockprotocol/tap

# 5. Install Core Tools & AI Suite
brew install uv ripgrep bat eza fzf zoxide walk syft yq gum aichat block-goose-cli gemini-cli mods ramalama llm opencode qwen-code whisper-cpp clio crush

brew cleanup
echo "✅ Homebrew setup complete."
