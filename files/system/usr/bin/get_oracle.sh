#!/bin/bash
set -e
MODEL_URL="https://huggingface.co/bartowski/Llama-3.3-70B-Instruct-GGUF/resolve/main/Llama-3.3-70B-Instruct-Q4_K_M.gguf"
TARGET_DIR="/var/shared/ai-models"
FILENAME="Llama-3.3-70B-Instruct-Q4_K_M.gguf"
FILE_PATH="${TARGET_DIR}/${FILENAME}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating model directory at $TARGET_DIR..."
    mkdir -p "$TARGET_DIR"
    chmod 775 "$TARGET_DIR"
fi

if [ -f "$FILE_PATH" ]; then
    echo "✅ Model $FILENAME already exists."
    exit 0
fi

echo "⬇️ Downloading Oracle Model (Llama 3.3 70B)..."
curl -L -C - --output "$FILE_PATH" "$MODEL_URL"
echo "✅ Download complete."
chmod 644 "$FILE_PATH"
echo "🎉 Oracle Model Ready."
