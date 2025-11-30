#!/bin/bash
set -eux pipefail
echo "🍺 Setting up and Installing Homebrew Packages (using gosu)..."

# 0. Ensure gosu is installed (you must install this as an earlier build step if not present)
# For BlueBuild Fedora-based images, you may need an 'rpm-ostree install -y gosu' in an earlier module if it fails here.
# gosu is installed here so it's immediately available
rpm-ostree install -y curl git make procps findutils shadow-utils gosu

# Define the user we want to run as (UID 1000 is the first user created on the OS)
TARGET_UID=1000
TARGET_USER="blue" # Ublue default user name


# 1. Install Prerequisites
rpm-ostree install -y git curl procps-ng

# Define the target non-root user UID
TARGET_UID=1000

# 2. Pre-create the directory (Atomic Safe Method)
mkdir -p /var/home/linuxbrew/.linuxbrew

# Ensure the symlink path works (in case the installer uses it)
if [ ! -d "/home/linuxbrew" ]; then
    ln -s /var/home/linuxbrew /home/linuxbrew
fi

# Change ownership of the directory structure to the non-root user *before* running the installer
chown -R $TARGET_UID:$TARGET_UID /var/home/linuxbrew


# NOTE: You had this line which you should remove from THIS script:
# gosu builduser /tmp/scripts/install_kvmfr.sh


# 3. Install Homebrew (Unattended)
# We MUST use 'gosu' here to run this specific command as the non-root user (UID 1000)
# This bypasses the "don't run this as root!" error.
gosu "$TARGET_UID" CI=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


# 4. Configure Environment
# We need to capture the shellenv as the non-root user, but running it directly in this root script is tricky.
# We skip 'eval' here, as we run subsequent commands explicitly with 'gosu'.


# 5. Tap Repositories (run as non-root)
echo "🔌 Tapping Repositories..."
gosu "$TARGET_UID" /home/linuxbrew/.linuxbrew/bin/brew tap charmbracelet/tap
gosu "$TARGET_UID" /home/linuxbrew/.linuxbrew/bin/brew tap gptscript-ai/tap
gosu "$TARGET_UID" /home/linuxbrew/.linuxbrew/bin/brew tap blockprotocol/tap

# 6. Install Packages (run as non-root)
echo "⬇️  Installing Tools..."
gosu "$TARGET_UID" /home/linuxbrew/.linuxbrew/bin/brew install uv ripgrep bat eza fzf zoxide walk syft yq \
    gum aichat block-goose-cli gemini-cli mods ramalama llm \
    opencode qwen-code whisper-cpp clio crush

# 7. Cleanup (run as non-root)
gosu "$TARGET_UID" /home/linuxbrew/.linuxbrew/bin/brew cleanup

# 8. Fix Permissions for UID 1000 (already done in step 2, but harmless to repeat)
echo "🔒 Setting permissions for future user..."
chown -R 1000:1000 /var/home/linuxbrew

echo "✅ Homebrew setup complete."

