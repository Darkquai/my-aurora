#!/bin/bash
set -e
MODEL_URL="https://huggingface.co/bartowski/Llama-3.3-70B-Instruct-GGUF/resolve/main/Llama-3.3-70B-Instruct-Q4_K_M.gguf"
TARGET_DIR="/var/shared/ai-models"
FILENAME="Llama-3.3-70B-Instruct-Q4_K_M.gguf"
FILE_PATH="${TARGET_DIR}/${FILENAME}"
LINK_PATH="${TARGET_DIR}/current_oracle.gguf"

mkdir -p "$TARGET_DIR"
chmod 777 "$TARGET_DIR"

if [ -f "$FILE_PATH" ]; then
    echo "✅ Oracle Model exists."
else
    echo "⬇️ Downloading Oracle Model (70B)..."
    curl -L -C - --output "$FILE_PATH" "$MODEL_URL"
    chmod 644 "$FILE_PATH"
fi

# Update symlink
ln -sf "$FILE_PATH" "$LINK_PATH"
echo "✅ Model Ready."
