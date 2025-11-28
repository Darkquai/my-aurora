#!/bin/bash
set -e
GPU_AUDIO_ID=$(lspci -nn | grep -i nvidia | grep Audio | grep -oP '\[\K[^\]]+')
GPU_VIDEO_ID=$(lspci -nn | grep -i nvidia | grep VGA | grep -oP '\[\K[^\]]+')

MODE=$1

function bind_driver() {
    local dev=$1
    local driver=$2
    local bus_id=$(lspci -nn | grep "$dev" | awk '{print $1}')
    if [ -e "/sys/bus/pci/devices/0000:$bus_id/driver" ]; then
        echo "0000:$bus_id" > /sys/bus/pci/devices/0000:$bus_id/driver/unbind
    fi
    echo "$driver" > /sys/bus/pci/devices/0000:$bus_id/driver_override
    echo "0000:$bus_id" > /sys/bus/pci/drivers/$driver/bind
    echo "" > /sys/bus/pci/devices/0000:$bus_id/driver_override
}

if [ "$MODE" == "vm" ]; then
    echo "🎮 Switching to Windows VM Mode..."
    # Stops SYSTEM services (no --user flag)
    systemctl stop scout.service oracle.service || true
    echo "   Closing processes..."
    # Force Linux to release the card (Monitor fix)
    fuser -k -v -9 /dev/nvidia0 >/dev/null 2>&1 || true
    systemctl stop nvidia-persistenced || true
    modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia || true
    modprobe vfio-pci
    bind_driver "$GPU_VIDEO_ID" "vfio-pci"
    bind_driver "$GPU_AUDIO_ID" "vfio-pci"
    echo "✅ Ready for Windows."

elif [ "$MODE" == "ai" ]; then
    echo "🧠 Switching to AI Mode..."
    if virsh list --state-running | grep -q "win11"; then
        echo "❌ Error: Windows VM is running."
        exit 1
    fi
    bind_driver "$GPU_VIDEO_ID" "nvidia"
    bind_driver "$GPU_AUDIO_ID" "snd_hda_intel"
    modprobe nvidia nvidia_modeset nvidia_drm nvidia_uvm
    systemctl start scout.service oracle.service
    echo "✅ AI Systems Online."
fi
