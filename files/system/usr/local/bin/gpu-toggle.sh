#!/bin/bash

# AUTO-DETECT GPU IDs
GPU_AUDIO_ID=$(lspci -nn | grep -i nvidia | grep Audio | grep -oP '\[\K[^\]]+')
GPU_VIDEO_ID=$(lspci -nn | grep -i nvidia | grep VGA | grep -oP '\[\K[^\]]+')

function mode_ai() {
    echo "🤖 Switching to AI Mode (Linux Host)..."
    # Bind to Nvidia Driver
    for dev in $GPU_VIDEO_ID $GPU_AUDIO_ID; do
        echo "$dev" > /sys/bus/pci/devices/0000:${dev%:*}/driver/unbind
        echo "$dev" > /sys/bus/pci/drivers/nvidia/bind
    done
    # RESTART AI SERVICES
    echo "🚀 Starting Scout Swarm..."
    systemctl start scout.service
    echo "✅ AI Mode Active."
}

function mode_vm() {
    echo "🎮 Switching to VM Mode (Windows Passthrough)..."
    
    # CRITICAL FIX: STOP AI BEFORE UNBINDING
    echo "🛑 Stopping Scout Swarm to release GPU..."
    systemctl stop scout.service
    
    # Kill any lingering processes on Nvidia card
    fuser -k -v -9 /dev/nvidia0 >/dev/null 2>&1 || true

    # Bind to VFIO
    modprobe vfio-pci
    for dev in $GPU_VIDEO_ID $GPU_AUDIO_ID; do
        echo "$dev" > /sys/bus/pci/devices/0000:${dev%:*}/driver/unbind
        echo "$dev" > /sys/bus/pci/drivers/vfio-pci/bind
    done
    echo "✅ VM Mode Active. Ready for Windows."
}

case "$1" in
    ai) mode_ai ;;
    vm) mode_vm ;;
    *) echo "Usage: $0 {ai|vm}"; exit 1 ;;
esac
