#!/bin/sh
set -oeux pipefail

echo "🖥️ Installing KVMFR / Looking Glass Drivers..."
ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

# Handle Rawhide mapping (The Fix)
if [[ "${RELEASE}" -ge 41 ]]; then
    COPR_RELEASE="rawhide"
else
    COPR_RELEASE="${RELEASE}"
fi

# 1. Install the Driver (HikariKnight)
wget "https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-${COPR_RELEASE}/hikariknight-looking-glass-kvmfr-fedora-${COPR_RELEASE}.repo" -O /etc/yum.repos.d/_copr_hikariknight.repo
rpm-ostree install -y akmod-kvmfr
akmods --force --kernels "${KERNEL}" --kmod kvmfr

# 2. Install the Client (PGaskin)
wget "https://copr.fedorainfracloud.org/coprs/pgaskin/looking-glass-client/repo/fedora-${COPR_RELEASE}/pgaskin-looking-glass-client-fedora-${COPR_RELEASE}.repo" -O /etc/yum.repos.d/_copr_pgaskin.repo
rpm-ostree install -y looking-glass-client

# Cleanup
rm -f /etc/yum.repos.d/_copr_hikariknight.repo
rm -f /etc/yum.repos.d/_copr_pgaskin.repo

echo "✅ KVMFR Installation Complete."
