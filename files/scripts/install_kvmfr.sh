#!/bin/sh
set -oeux pipefail

# scripts/install_kvmfr.sh
# Rationale: Builds the KVMFR akmod from source using the provided spec file,
# as the F43 COPR package is unavailable.

ARCH="$(rpm -E '%_arch')"
KERNEL_VERSION="$(rpm -q "${KERNEL_NAME:-kernel}" --queryformat '%{VERSION}-%{RELEASE}')"
RELEASE="$(rpm -E '%fedora')"

REPO_URL="REPO_URL="https://github.com/HikariKnight/looking-glass-kvmfr-akmod.git"
"
BUILD_DIR="/tmp/kvmfr_build"
SPEC_FILE="kvmfr.spec" # Use the generic spec file provided in the repo

echo "Building KVMFR akmod from source for Fedora ${RELEASE} Kernel ${KERNEL_VERSION}"

# Install build dependencies required by the spec file (gcc, make, etc.)
rpm-ostree install 'kernel-devel' 'rpm-build' 'wget' 'git' 'make' 'gcc'

# Clone the source repository
git clone "$REPO_URL" "$BUILD_DIR"
cd "$BUILD_DIR"

# Use rpmbuild to build the package from the spec file
rpmbuild -bb "$SPEC_FILE"

# Find the newly created RPM file path
KMOD_RPM=$(find /root/rpmbuild/RPMS/ -name "akmod-kvmfr-*.rpm")

if [ -z "$KMOD_RPM" ]; then
    echo "Error: KVMFR RPM not found after build."
    exit 1
fi

echo "Installing built KVMFR RPM: $KMOD_RPM"

# Install the built RPM using rpm-ostree
rpm-ostree install "$KMOD_RPM"

# Clean up build directory
rm -rf "$BUILD_DIR"
