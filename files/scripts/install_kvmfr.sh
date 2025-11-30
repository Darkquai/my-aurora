#!/bin/bash
set -ouex pipefail

echo "🔧 Building KVMFR Akmod from source (Independent Build)..."

# 1. Install Build Dependencies
# We need these to compile the RPM.
# 'akmods' and 'rpm-build' are critical.
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
# We clone the HikariKnight wrapper which contains the logic to build the Akmod
git clone https://github.com/HikariKnight/looking-glass-kvmfr-akmod.git .

# 4. ⚠️ CRITICAL FIX: Sanitize the Spec File ⚠️
# The repo uses 'rpkg' macros ({{{ git_dir_version }}}) which break standard builds.
# We will use sed to replace them with actual values.

# A. Generate a version number from git (e.g., 0.0.1) or use a static one
# If git describe fails, fallback to "1.0.0"
VERSION=$(git describe --tags --always --long | sed 's/^v//;s/-/_/g' || echo "1.0.0")
echo "   -> Detected Version: $VERSION"

# B. Create the Source Tarball manually (Replacing {{{ git_dir_pack }}})
tar -czf "kvmfr-${VERSION}.tar.gz" --exclude .git .

# C. Patch the kvmfr.spec file
# Replace Version macro
sed -i "s/Version:.*{{{ git_dir_version }}}/Version: $VERSION/" kvmfr.spec
# Replace Release macro
sed -i "s/Release:.*{{{ git_dir_release }}}/Release: 1%{?dist}/" kvmfr.spec
# Replace Source0 macro with our tarball
sed -i "s/Source0:.*{{{ git_dir_pack.*}}}/Source0: kvmfr-${VERSION}.tar.gz/" kvmfr.spec
# Remove any other rpkg specific lines if they exist
sed -i '/VCS:/d' kvmfr.spec

echo "   -> Spec file sanitized for standard rpmbuild."

# 5. Prepare RPM Build Tree
rpmdev-setuptree
cp "kvmfr-${VERSION}.tar.gz" ~/rpmbuild/SOURCES/
cp kvmfr.spec ~/rpmbuild/SPECS/

# 6. Build the RPM
# -bb means build binary (the akmod package)
echo "🔨 Running rpmbuild..."
rpmbuild -bb ~/rpmbuild/SPECS/kvmfr.spec

# 7. Install the Resulting RPM
# The build will output an RPM in ~/rpmbuild/RPMS/x86_64/ (or noarch)
echo "📦 Installing generated RPM..."
rpm-ostree install ~/rpmbuild/RPMS/*/akmod-kvmfr*.rpm

# 8. Clean up
cd /
rm -rf "$BUILD_DIR"
rm -rf ~/rpmbuild

echo "✅ KVMFR Akmod installed successfully."
