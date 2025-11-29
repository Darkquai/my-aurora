#!/bin/bash
set -e
DOCS_DIR="$HOME/Documents/AI_Library"
echo "🧠 Initializing Darkquai Memory Layer..."
if [ ! -d "$DOCS_DIR" ]; then
    mkdir -p "$DOCS_DIR"
fi
echo "🔒 Applying SELinux Context to Documents..."
chcon -R -t container_file_t "$DOCS_DIR"
echo "✅ RAG Configuration Complete."
