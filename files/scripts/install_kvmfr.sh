#!/bin/bash
set -ouex pipefail

echo "🔧 Building KVMFR Akmod from source (Independent Build)..."

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

# 4. Sanitize the Spec File
VERSION=$(git describe --tags --always --long | sed 's/^v//;s/-/_/g' || echo "1.0.0")
echo "   -> Detected Version: $VERSION"

# FIX: Write tarball to /tmp (outside current dir) to prevent 'file changed' error
tar -czf "/tmp/kvmfr-${VERSION}.tar.gz" --exclude .git .

# Patch the spec file
sed -i "s/Version:.*{{{ git_dir_version }}}/Version: $VERSION/" kvmfr.spec
sed -i "s/Release:.*{{{ git_dir_release }}}/Release: 1%{?dist}/" kvmfr.spec
sed -i "s/Source0:.*{{{ git_dir_pack.*}}}/Source0: kvmfr-${VERSION}.tar.gz/" kvmfr.spec
sed -i '/VCS:/d' kvmfr.spec

echo "   -> Spec file sanitized."

# 5. Build RPM
rpmdev-setuptree
# Copy the tarball from /tmp to the SOURCES directory
cp "/tmp/kvmfr-${VERSION}.tar.gz" ~/rpmbuild/SOURCES/
cp kvmfr.spec ~/rpmbuild/SPECS/

echo "🔨 Running rpmbuild..."
rpmbuild -bb ~/rpmbuild/SPECS/kvmfr.spec

# 6. Install RPM
echo "📦 Installing generated RPM..."
rpm-ostree install ~/rpmbuild/RPMS/*/akmod-kvmfr*.rpm

# 7. Cleanup
cd /
rm -rf "$BUILD_DIR"
rm -f "/tmp/kvmfr-${VERSION}.tar.gz"
rm -rf ~/rpmbuild

echo "✅ KVMFR Akmod installed successfully."
