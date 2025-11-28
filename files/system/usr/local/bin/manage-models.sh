#!/bin/bash
set -e
STORAGE_DIR="/var/lib/ai-storage/models"
SCOUT_ENV="/etc/vllm/scout.env"

echo "🧠 Darkquai AI System Manager"
echo "============================"
echo "Shared Storage: $STORAGE_DIR"
echo ""

echo "--- 🏎️  SCOUT (GPU) SELECTION (vLLM Engine) ---"
echo "1. Josiefied Qwen 2.5 7B (Fast, Uncensored) [Default]"
echo "2. Qwen 2.5 Coder 7B (Fast Coding)"
echo "3. Qwen 2.5 Coder 32B (Heavy Coding - Requires ~20GB VRAM)"
echo "4. Enter Custom HuggingFace Tag"

read -p "Select Scout: " scout_opt

MODEL=""
if [ "$scout_opt" == "1" ]; then
    MODEL="Isaak-Carter/Josiefied-Qwen2.5-7B-Instruct-abliterated-v2"
elif [ "$scout_opt" == "2" ]; then
    MODEL="Qwen/Qwen2.5-Coder-7B-Instruct"
elif [ "$scout_opt" == "3" ]; then
    MODEL="Qwen/Qwen2.5-Coder-32B-Instruct"
elif [ "$scout_opt" == "4" ]; then
    read -p "Enter Tag: " MODEL
fi

if [ ! -z "$MODEL" ]; then
    echo "Updating Scout Configuration..."
    sudo sed -i "s|MODEL_NAME=.*|MODEL_NAME=$MODEL|" $SCOUT_ENV
    echo "✅ Scout set to $MODEL."
fi

echo ""
echo "--- 🔮 ORACLE (CPU) SELECTION (Llama Engine) ---"
echo "1. Calme 3.2 78B (Top Reasoning) [~50GB]"
echo "2. Qwen2-VL 72B (Vision/Multimodal) [~48GB]"
echo "3. Import from Ramalama (Use 'ramalama pull' first)"

read -p "Select Oracle: " oracle_opt

URL=""
FILENAME=""

if [ "$oracle_opt" == "1" ]; then
    # VERIFIED LINK: Calme 78B Q4_K_M
    URL="https://huggingface.co/MaziyarPanahi/calme-3.2-instruct-78b-GGUF/resolve/main/calme-3.2-instruct-78b.Q4_K_M.gguf"
    FILENAME="current_oracle.gguf"
elif [ "$oracle_opt" == "2" ]; then
    # VERIFIED LINK: Qwen2-VL 72B Q4_K_M
    URL="https://huggingface.co/Qwen/Qwen2-VL-72B-Instruct-GGUF/resolve/main/qwen2-vl-72b-instruct-q4_k_m.gguf"
    FILENAME="current_oracle.gguf"
elif [ "$oracle_opt" == "3" ]; then
    echo "Files in $STORAGE_DIR:"
    ls -1 $STORAGE_DIR/*.gguf 2>/dev/null || echo "No GGUF files found."
    read -p "Enter filename to activate: " custom_file
    if [ -f "$STORAGE_DIR/$custom_file" ]; then
        # Create a Symlink so the Service always sees 'current_oracle.gguf'
        sudo ln -sf "$STORAGE_DIR/$custom_file" "$STORAGE_DIR/current_oracle.gguf"
        echo "✅ Linked $custom_file to Oracle."
        URL="" # Skip download
    else
        echo "❌ File not found."
    fi
fi

if [ ! -z "$URL" ]; then
    echo "⬇️  Downloading Oracle to Shared Storage..."
    sudo curl -L -C - --output "$STORAGE_DIR/$FILENAME" "$URL"
    sudo chmod 644 "$STORAGE_DIR/$FILENAME"
    echo "✅ Oracle Updated."
fi

echo ""
echo "🔄 Restarting AI Services..."
sudo systemctl restart scout.service oracle.service
echo "✅ AI Systems Online."
