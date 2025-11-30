#!/bin/bash
set -ouex pipefail

echo "🔧 Building KVMFR Akmod from source (Nuclear Fix)..."

# 1. Install Build Dependencies (Layered temporarily)
# We use dnf here so we don't commit build tools to the final ostree if we can avoid it, 
# but rpm-ostree is safer for the final artifact.
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

# 4. Generate Version and Source Tarball
VERSION=$(git describe --tags --always --long | sed 's/^v//;s/-/_/g' || echo "1.0.0")
echo "   -> Detected Version: $VERSION"

# Create tarball in /tmp to avoid "file changed" errors
TAR_NAME="kvmfr-${VERSION}.tar.gz"
tar -czf "/tmp/${TAR_NAME}" --exclude .git .

# 5. ⚠️ AGGRESSIVE SPEC FILE REPAIR ⚠️
echo "   -> Patching Spec File..."

# Force-replace Version, Release, and Source0
sed -i "s/^Version:.*$/Version: ${VERSION}/" kvmfr.spec
sed -i "s/^Release:.*$/Release: 1%{?dist}/" kvmfr.spec
sed -i "s/^Source0:.*$/Source0: ${TAR_NAME}/" kvmfr.spec

# Remove broken VCS/Git tags
sed -i '/^VCS:/d' kvmfr.spec

# DELETE the broken %changelog section entirely
sed -i '/^%changelog/,$d' kvmfr.spec

# Write a clean, valid changelog
cat <<CHANGELOG >> kvmfr.spec
%changelog
* $(date "+%a %b %d %Y") AutoBuilder <builder@local> - ${VERSION}-1
- Automated build fix
CHANGELOG

# 6. Build RPM
rpmdev-setuptree
cp "/tmp/${TAR_NAME}" ~/rpmbuild/SOURCES/
cp kvmfr.spec ~/rpmbuild/SPECS/

echo "🔨 Running rpmbuild..."
rpmbuild -bb ~/rpmbuild/SPECS/kvmfr.spec

# 7. Install the Resulting RPM
echo "📦 Installing generated RPM..."
rpm-ostree install ~/rpmbuild/RPMS/*/akmod-kvmfr*.rpm

# 8. Install V4L2Loopback (Virtual Webcam) - Since we are here
rpm-ostree install akmod-v4l2loopback

# 9. Install Looking Glass Client (From PGaskin Repo)
wget "https://copr.fedorainfracloud.org/coprs/pgaskin/looking-glass-client/repo/fedora-rawhide/pgaskin-looking-glass-client-fedora-rawhide.repo" -O /etc/yum.repos.d/_copr_pgaskin.repo
rpm-ostree install looking-glass-client
rm -f /etc/yum.repos.d/_copr_pgaskin.repo

# 10. Configuration & Cleanup
# KVMFR Config
echo "options kvmfr static_size_mb=256" > /etc/modprobe.d/kvmfr.conf
echo 'SUBSYSTEM=="kvmfr", OWNER="1000", GROUP="kvm", MODE="0660"' > /etc/udev/rules.d/99-kvmfr.rules
mkdir -p /etc/kvmfr/selinux/{mod,pp}

# Cleanup Build Artifacts
cd /
rm -rf "$BUILD_DIR"
rm -f "/tmp/${TAR_NAME}"
rm -rf ~/rpmbuild

echo "✅ KVMFR System Installed Successfully."
