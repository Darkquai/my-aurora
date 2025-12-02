# @recipe
mode-vm:
    @echo "🔌 Preparing GPU for Windows..."
    sudo /usr/local/bin/gpu-toggle.sh vm

# @recipe
mode-ai:
    @echo "🔌 Preparing GPU for Linux AI..."
    sudo /usr/local/bin/gpu-toggle.sh ai

# @recipe
setup-ai:
    @echo "📥 Downloading AI Models..."
    sudo /usr/local/bin/get_oracle.sh

# @recipe
mission-control:
    @echo "🛰️ Launching Dashboard..."
    /usr/local/bin/mission-control

# @recipe
system-detox:
    @echo "🧹 Cleaning System..."
    sudo /usr/local/bin/system-detox
