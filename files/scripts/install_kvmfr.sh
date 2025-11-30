#!/bin/bash
set -ouex pipefail

echo "🔧 Building KVMFR Akmod from source (Final Fix)..."

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

# 4. Generate Version and Source Tarball
VERSION=$(git describe --tags --always --long | sed 's/^v//;s/-/_/g' || echo "1.0.0")
echo "   -> Detected Version: $VERSION"

TAR_NAME="kvmfr-${VERSION}.tar.gz"
tar -czf "/tmp/${TAR_NAME}" --exclude .git .

# 5. ⚠️ SPEC FILE REPAIR ⚠️

# A. Replace Header Macros
sed -i "s/^Version:.*$/Version: ${VERSION}/" kvmfr.spec
sed -i "s/^Release:.*$/Release: 1%{?dist}/" kvmfr.spec
sed -i "s/^Source0:.*$/Source0: ${TAR_NAME}/" kvmfr.spec
sed -i '/^VCS:/d' kvmfr.spec

# B. FIX THE DIRECTORY STRUCTURE ERROR (The new fix)
# The spec file tries to cd into a directory that doesn't exist in our tarball.
# We delete the lines that mention 'looking-glass-kvmfr-akmod-main'
sed -i 's|looking-glass-kvmfr-akmod-main/||g' kvmfr.spec

# C. Rewrite Changelog
sed -i '/^%changelog/,$d' kvmfr.spec
cat <<EOF >> kvmfr.spec
%changelog
* $(date "+%a %b %d %Y") AutoBuilder <builder@local> - ${VERSION}-1
- Automated build fix
EOF

echo "   -> Spec file forced to compliance."

# 6. Build RPM
rpmdev-setuptree
cp "/tmp/${TAR_NAME}" ~/rpmbuild/SOURCES/
cp kvmfr.spec ~/rpmbuild/SPECS/

echo "🔨 Running rpmbuild..."
rpmbuild -bb ~/rpmbuild/SPECS/kvmfr.spec

# 7. Install RPM
echo "📦 Installing generated RPM..."
rpm-ostree install ~/rpmbuild/RPMS/*/akmod-kvmfr*.rpm

# 8. Cleanup
cd /
rm -rf "$BUILD_DIR"
rm -f "/tmp/${TAR_NAME}"
rm -rf ~/rpmbuild

echo "✅ KVMFR Akmod installed successfully."
