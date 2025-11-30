#!/bin/bash
set -ouex pipefail

echo "🔧 Building KVMFR Akmod (Robust Mode)..."

# 1. Install Build Dependencies
rpm-ostree install \
    rpm-build \
    rpmdevtools \
    gcc \
    make \
    git \
    akmods \
    kernel-devel \
    systemd-rpm-macros

# 2. Set up Build Environment
BUILD_DIR="/tmp/kvmfr_build"
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# 3. Clone the Repository
git clone https://github.com/HikariKnight/looking-glass-kvmfr-akmod.git .

# 4. Generate Tarball
VERSION=$(git describe --tags --always --long | sed 's/^v//;s/-/_/g' || echo "1.0.0")
echo "   -> Detected Version: $VERSION"
TAR_NAME="kvmfr-${VERSION}.tar.gz"
tar -czf "/tmp/${TAR_NAME}" --exclude .git .

# 5. ⚠️ PATCHING SPEC FILE (With Space/Tab Tolerance) ⚠️
echo "   -> Patching Spec File..."

# Regex Explanation:
# ^\s*   -> Match start of line followed by any amount of whitespace
# Source0? -> Match 'Source' or 'Source0'
# :.*$   -> Match the colon and everything after it

sed -i -E "s/^\s*Version:.*$/Version: ${VERSION}/" kvmfr.spec
sed -i -E "s/^\s*Release:.*$/Release: 1%{?dist}/" kvmfr.spec
sed -i -E "s/^\s*Source0?:.*$/Source0: ${TAR_NAME}/" kvmfr.spec

# Remove Git/VCS tags
sed -i '/^VCS:/d' kvmfr.spec

# DELETE the broken %changelog section
sed -i '/^%changelog/,$d' kvmfr.spec

# Write a fresh changelog
cat <<CHANGELOG >> kvmfr.spec
%changelog
* $(date "+%a %b %d %Y") AutoBuilder <builder@local> - ${VERSION}-1
- Automated build fix
CHANGELOG

# 6. Build RPM
rpmdev-setuptree
# Copy our custom tarball
cp "/tmp/${TAR_NAME}" ~/rpmbuild/SOURCES/

# FAILSAFE: Create a 'main.tar.gz' decoy just in case patching failed silently
cp "/tmp/${TAR_NAME}" ~/rpmbuild/SOURCES/main.tar.gz

cp kvmfr.spec ~/rpmbuild/SPECS/

echo "🔨 Running rpmbuild..."
# Using -bb (Build Binary) directly
rpmbuild -bb ~/rpmbuild/SPECS/kvmfr.spec

# 7. Install
echo "📦 Installing generated RPM..."
rpm-ostree install ~/rpmbuild/RPMS/*/akmod-kvmfr*.rpm

# 8. Install V4L2 & Client
rpm-ostree install akmod-v4l2loopback
wget "https://copr.fedorainfracloud.org/coprs/pgaskin/looking-glass-client/repo/fedora-rawhide/pgaskin-looking-glass-client-fedora-rawhide.repo" -O /etc/yum.repos.d/_copr_pgaskin.repo
rpm-ostree install looking-glass-client
rm -f /etc/yum.repos.d/_copr_pgaskin.repo

# 9. Cleanup
echo "🧹 Cleaning up..."
cd /
rm -rf "$BUILD_DIR"
rm -f "/tmp/${TAR_NAME}"
rm -rf ~/rpmbuild

echo "✅ KVMFR Installation Complete."
