#!/bin/sh
set -oeux pipefail

echo "🖥️ Installing KVMFR & Virtualization Support..."

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

# Handle Rawhide mapping for COPR
if [[ "${RELEASE}" -ge 41 ]]; then
    COPR_RELEASE="rawhide"
else
    COPR_RELEASE="${RELEASE}"
fi

# --- Install Drivers (RPMs) ---
wget "https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-${COPR_RELEASE}/hikariknight-looking-glass-kvmfr-fedora-${COPR_RELEASE}.repo" -O /etc/yum.repos.d/_copr_hikariknight.repo

# Install KVMFR and V4L2Loopback (Virtual Webcam)
rpm-ostree install -y akmod-kvmfr akmod-v4l2loopback
akmods --force --kernels "${KERNEL}" --kmod kvmfr
akmods --force --kernels "${KERNEL}" --kmod v4l2loopback

# Install Looking Glass Client
wget "https://copr.fedorainfracloud.org/coprs/pgaskin/looking-glass-client/repo/fedora-${COPR_RELEASE}/pgaskin-looking-glass-client-fedora-${COPR_RELEASE}.repo" -O /etc/yum.repos.d/_copr_pgaskin.repo
rpm-ostree install -y looking-glass-client

# Cleanup Repos
rm -f /etc/yum.repos.d/_copr_hikariknight.repo
rm -f /etc/yum.repos.d/_copr_pgaskin.repo

# --- Configure KVMFR Memory ---
echo "options kvmfr static_size_mb=256" > /etc/modprobe.d/kvmfr.conf

# --- Configure UDEV Rules ---
echo 'SUBSYSTEM=="kvmfr", OWNER="1000", GROUP="kvm", MODE="0660"' > /etc/udev/rules.d/99-kvmfr.rules

# --- Configure Looking Glass Client ---
cat <<INI > /etc/looking-glass-client.ini
[app]
shmFile=/dev/kvmfr0
INI

# --- Configure SELinux ---
mkdir -p /etc/kvmfr/selinux/{mod,pp}
cat <<SELINUX > /etc/kvmfr/selinux/kvmfr.te
module kvmfr 1.0;
require {
    type device_t;
    type svirt_t;
    class chr_file { open read write map };
}
allow svirt_t device_t:chr_file { open read write map };
SELINUX

checkmodule -M -m -o /etc/kvmfr/selinux/mod/kvmfr.mod /etc/kvmfr/selinux/kvmfr.te
semodule_package -o /etc/kvmfr/selinux/pp/kvmfr.pp -m /etc/kvmfr/selinux/mod/kvmfr.mod

echo "✅ Drivers & Configuration Installed."
