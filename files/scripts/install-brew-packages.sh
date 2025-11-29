#!/bin/bash
set -e
echo "🍺 Installing Homebrew Packages..."
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
brew tap charmbracelet/tap
brew tap gptscript-ai/tap
brew tap blockprotocol/tap
brew install uv ripgrep bat eza fzf zoxide walk syft yq gum aichat block-goose-cli gemini-cli mods ramalama llm opencode qwen-code whisper-cpp clio crush
brew cleanup
echo "✅ Homebrew setup complete."
