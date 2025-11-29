#!/bin/bash
set -e

# --- Install Core Packages ---
echo "--> Updating and installing System packages..."
sudo dnf install -y python3-devel gcc ansible nodejs npm ripgrep fzf graphviz unzip which jq

# --- Install OpenTofu (Terraform replacement) ---
if ! command -v tofu &> /dev/null; then
    echo "--> Installing OpenTofu..."
    curl --proto "=https" --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
    chmod +x install-opentofu.sh
    ./install-opentofu.sh --install-method rpm
    rm install-opentofu.sh
fi

# --- Install UV ---
if ! command -v uv &> /dev/null; then
    echo "--> Installing UV..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# --- Create the Dynamic Greeting (MOTD) ---
# This generates the exact table structure you requested
echo "--> Installing Dynamic Greeting..."
sudo tee /usr/local/bin/sys-welcome > /dev/null << 'BASH'
#!/bin/bash
# Colors
G='\033[1;32m' # Green
B='\033[1;34m' # Blue
Y='\033[1;33m' # Yellow
W='\033[1;37m' # White
NC='\033[0m'   # No Color

# Get Versions dynamically
PY_VER=$(python3 --version 2>&1 | awk '{print $2}')
ANS_VER=$(ansible --version 2>&1 | head -n1 | awk '{print $2}' | tr -d ']')
TOFU_VER=$(tofu --version 2>&1 | head -n1)
UV_STATUS=$(command -v uv >/dev/null && echo "Found" || echo "Missing")

# Render the Table
echo -e "${B}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${B}║${Y} 🛠️  SYSTEM DEVELOPMENT CORE (sys-core)             ${B}║${NC}"
echo -e "${B}╠════════════════════════════════════════════════════╣${NC}"
echo -e "${B}║${NC} This is your mutable Fedora bridge.                ${B}║${NC}"
echo -e "${B}╠════════════════════════════════════════════════════╣${NC}"
echo -e "${B}║${W} 📊 INSTALLED TOOLCHAIN STATUS                      ${B}║${NC}"
echo -e "${B}║${G}   🐍 Python:    ${W}${PY_VER}                       ${B}║${NC}"
echo -e "${B}║${G}   ⚡ Ansible:   ${W}${ANS_VER}                      ${B}║${NC}"
echo -e "${B}║${G}   🌪️  UV:        ${W}${UV_STATUS}                           ${B}║${NC}"
echo -e "${B}║${G}   🏗️  Terraform: ${W}${TOFU_VER}                   ${B}║${NC}"
echo -e "${B}║                                                    ${B}║${NC}"
echo -e "${B}║ ${Y}🔗 Exported to Host:${NC}                               ${B}║${NC}"
echo -e "${B}║    sys-py, uv, ansible, tofu, jq, rg, fzf          ${B}║${NC}"
echo -e "${B}║                                                    ${B}║${NC}"
echo -e "${B}║ ${Y}📦 Install New Tools:${NC}                              ${B}║${NC}"
echo -e "${B}║    sudo dnf install <package>                      ${B}║${NC}"
echo -e "${B}║    (Then run: distrobox-export --bin <cmd>)        ${B}║${NC}"
echo -e "${B}╚════════════════════════════════════════════════════╝${NC}"
BASH

sudo chmod +x /usr/local/bin/sys-welcome

# Add greeting to .bashrc if not present
if ! grep -q "sys-welcome" ~/.bashrc; then
    echo "/usr/local/bin/sys-welcome" >> ~/.bashrc
fi

# --- Exports ---
echo "--> Exporting Binaries to Host..."
# Core
distrobox-export --bin "$(which uv)" --export-path ~/.local/bin
distrobox-export --bin /usr/bin/python3 --export-path ~/.local/bin
# Requested Fixes
distrobox-export --bin /usr/bin/pip3 --export-path ~/.local/bin
distrobox-export --bin /usr/bin/dot --export-path ~/.local/bin
# Ops & Dev
distrobox-export --bin /usr/bin/ansible --export-path ~/.local/bin
distrobox-export --bin /usr/bin/ansible-playbook --export-path ~/.local/bin
distrobox-export --bin /usr/bin/tofu --export-path ~/.local/bin
distrobox-export --bin /usr/bin/npm --export-path ~/.local/bin
distrobox-export --bin /usr/bin/node --export-path ~/.local/bin
distrobox-export --bin /usr/bin/rg --export-path ~/.local/bin
distrobox-export --bin /usr/bin/fzf --export-path ~/.local/bin
distrobox-export --bin /usr/bin/jq --export-path ~/.local/bin

echo "--> Provisioning Complete."
