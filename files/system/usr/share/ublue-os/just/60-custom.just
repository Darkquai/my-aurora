# @recipe
init-sys-core:
    @echo "⚠️  WARNING: This will DELETE and RECREATE the 'sys-core' container."
    @echo "All system packages inside the container will be lost."
    @echo "Files in your Home directory will be safe."
    @read -p "Are you sure you want to proceed? [y/N] " -n 1 -r; \
    echo ""; \
    if [[ ! $$REPLY =~ ^[Yy]$$ ]]; then \
        echo "❌ Aborted."; \
        exit 1; \
    fi
    @echo "🚀 Creating System Core..."
    -distrobox stop sys-core --yes
    -distrobox rm sys-core --yes
    distrobox create --name sys-core --image registry.fedoraproject.org/fedora-toolbox:latest --hostname sys-core --yes
    @echo "📦 Provisioning Packages..."
    # This trick reads the script from the HOST and runs it INSIDE the container
    distrobox enter sys-core -- bash -c "$$(cat /usr/bin/provision_sys_core.sh)"
    @echo "✅ System Core Ready."

# @recipe
new-project name:
    @echo "🏗️  Creating Project: {{name}}..."
    distrobox create --name {{name}} --image registry.fedoraproject.org/fedora-toolbox:latest --hostname {{name}} --yes
    @echo "🔧 Provisioning..."
    # This trick reads the script from the HOST and runs it INSIDE the container
    distrobox enter {{name}} -- bash -c "$$(cat /usr/bin/provision_project.sh)"
    @echo "✅ Project '{{name}}' ready."

# @recipe
enter-sys:
    distrobox enter sys-core


# @recipe
brew-help:
    @echo "🍺 Homebrew Cheatsheet for Aurora"
    @echo "---------------------------------------------------"
    @echo " install <pkg>    : Install a package"
    @echo " uninstall <pkg>  : Remove a package"
    @echo " update           : Update brew and formulae"
    @echo " upgrade          : Upgrade all installed packages"
    @echo " list             : List installed packages"
    @echo " search <text>    : Search for packages"
    @echo " info <pkg>       : Get info/version of a package"
    @echo " doctor           : Diagnose issues"
    @echo "---------------------------------------------------"
    @echo " 💡 Tip: Use 'ujust install-ai-tools' to refresh AI apps"

# @recipe
init-sys-core:
    @echo "🚀 Creating System Core..."
    -distrobox stop sys-core --yes
    -distrobox rm sys-core --yes
    distrobox create --name sys-core --image registry.fedoraproject.org/fedora-toolbox:latest --hostname sys-core --yes
    distrobox enter sys-core -- bash -c "$$(cat /usr/bin/provision_sys_core.sh)"
    @echo "✅ System Core Ready."

# @recipe
brew-help:
    @echo "🍺 Homebrew Cheatsheet"
    @echo "  brew install <pkg>   : Install a package"
    @echo "  brew list            : List installed packages"
    @echo "  brew update          : Update brew itself"
    @echo "  brew upgrade         : Upgrade all packages"

# @recipe
rl-help:
    @echo "🦙 Ramalama Cheatsheet"
    @echo "---------------------------------------------------"
    @echo "  rl pull <model>      : Download a model"
    @echo "  rl run <model>       : Chat with a model"
    @echo "  rl serve             : Start OpenAI-compatible server"
    @echo "  rl list              : Show downloaded models"
    @echo "---------------------------------------------------"
    @echo "  Backend: Nvidia CDI (Auto-detected)"

# @recipe
install-lmstudio:
    @echo "⬇️  Downloading LM Studio (AppImage)..."
    mkdir -p $HOME/Applications
    wget -O $HOME/Applications/LM-Studio.AppImage "https://releases.lmstudio.ai/linux/x86/0.3.6/beta/LM_Studio-0.3.6-beta-x86_64.AppImage"
    chmod +x $HOME/Applications/LM-Studio.AppImage
    @echo "✅ Installed to ~/Applications/LM-Studio.AppImage"

# @recipe
hive-start:
    @echo "🐝 Awakening the Hive..."
    /usr/local/bin/start_hive.sh
