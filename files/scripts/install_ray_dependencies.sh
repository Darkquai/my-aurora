#!/bin/bash
set -ouex pipefail
echo "📦 Installing AI Gateway Dependencies..."
pip install --prefix=/usr --no-cache-dir "ray[serve]" requests vllm openai
