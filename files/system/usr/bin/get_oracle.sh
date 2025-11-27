#!/bin/bash
set -e
# This URL points to the quantized 70B model
MODEL_URL="https://huggingface.co/bartowski/Llama-3.3-70B-Instruct-GGUF/resolve/main/Llama-3.3-70B-Instruct-Q4_K_M.gguf"
TARGET_DIR="/var/shared/ai-models"
FILENAME="Llama-3.3-70B-Instruct-Q4_K_M.gguf"
FILE_PATH="${TARGET_DIR}/${FILENAME}"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Creating model directory..."
    mkdir -p "$TARGET_DIR"
    chmod 775 "$TARGET_DIR"
fi

if [ -f "$FILE_PATH" ]; then
    echo "✅ Model exists."
    exit 0
fi

echo "⬇️ Downloading Oracle Model (~42GB)..."
curl -L -C - --output "$FILE_PATH" "$MODEL_URL"
chmod 644 "$FILE_PATH"
echo "✅ Oracle Model Ready."
