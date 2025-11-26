#!/bin/bash
set -e
HIVE_DIR="$HOME/.local/share/darkquai-hive"
SCRIPT="/usr/share/darkquai-ai/orchestrator.py"

echo "🐝 Initializing Darkquai Hive Mind..."
if [ ! -d "$HIVE_DIR" ]; then
    python3 -m venv "$HIVE_DIR"
    "$HIVE_DIR/bin/pip" install "ray[serve]" httpx starlette
fi

echo "🚀 Starting Ray Cluster..."
"$HIVE_DIR/bin/ray" stop --force || true
"$HIVE_DIR/bin/ray" start --head --dashboard-host=0.0.0.0 --port=6379 --disable-usage-stats

ln -sf "$SCRIPT" "$HIVE_DIR/target.py"
cd "$HIVE_DIR"
"$HIVE_DIR/bin/serve" run target:entrypoint
