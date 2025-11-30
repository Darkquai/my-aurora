#!/bin/sh
# files/usr/local/bin/install_gosu.sh
# NOTE: This script is a workaround because 'gosu' package was missing from Fedora 43 repos during the initial build phase.

GOSU_VERSION=1.16
ARCH=\$(uname -m)

if [ "\$ARCH" = "x86_64" ]; then
    GOSU_ARCH=amd64
elif [ "\$ARCH" = "aarch64" ]; then
    GOSU_ARCH=arm64
else
    echo "Unsupported architecture: \$ARCH"
    exit 1
fi

GOSU_URL="github.com\$GOSU_VERSION/gosu-\$GOSU_ARCH"
GOSU_DEST="/usr/local/bin/gosu" # <-- The destination path

echo "Downloading gosu \$GOSU_VERSION for \$GOSU_ARCH"
curl -L "\$GOSU_URL" -o "\$GOSU_DEST" # <-- The download command

if [ \$? -ne 0 ]; then
    echo "Failed to download gosu"
    exit 1
fi

chmod +x "\$GOSU_DEST"
echo "gosu installed successfully."
