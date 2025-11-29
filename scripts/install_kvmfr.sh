#!/bin/sh
set -oeux pipefail

ARCH="$(rpm -E '%_arch')"
KERNEL="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')"
RELEASE="$(rpm -E '%fedora')"

# Handle the Fedora 43 / Rawhide mapping
if [[ "${RELEASE}" -ge 41 ]]; then
    COPR_RELEASE="rawhide"
else
    COPR_RELEASE="${RELEASE}"
fi

# Download the repo manually
wget "https://copr.fedorainfracloud.org/coprs/hikariknight/looking-glass-kvmfr/repo/fedora-${COPR_RELEASE}/hikariknight-looking-glass-kvmfr-fedora-${COPR_RELEASE}.repo" -O /etc/yum.repos.d/_copr_hikariknight-looking-glass-kvmfr.repo

# Install the package
rpm-ostree install -y akmod-kvmfr

# Force the kernel module build
akmods --force --kernels "${KERNEL}" --kmod kvmfr

# Verify it worked
modinfo "/usr/lib/modules/${KERNEL}/extra/kvmfr/kvmfr.ko.xz" > /dev/null || (find /var/cache/akmods/kvmfr/ -name \*.log -print -exec cat {} \; && exit 1)

# Cleanup
rm -f /etc/yum.repos.d/_copr_hikariknight-looking-glass-kvmfr.repo
