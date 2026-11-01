#!/bin/bash
# ====================================================================
#  HeavenOS - Sandboxed Desktop Launcher
# ====================================================================

echo ""
echo "======================================================================"
echo "    HeavenOS - Sandboxed Desktop (Chrome Default)"
echo "    - Terminal Disabled"
echo "    - Desktop Right-Click Disabled"
echo "    - Dynamic App Install: bash add_app.sh <name>"
echo "======================================================================"
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe jao."
    exit 1
fi

# Stop previous session
echo "[→] Stopping previous session if running..."
docker rm -f heaven-kiosk 2>/dev/null || true

# Build Image
echo "[→] Building HeavenOS image (Fast Build - Chrome Only)..."
export DOCKER_BUILDKIT=1
docker build -t heaven-kiosk .
if [ $? -ne 0 ]; then
    echo "ERROR: Docker build fail ho gaya! Check disk space with 'df -h'."
    exit 1
fi

# Run Container
echo "[→] Starting HeavenOS Container on Port 8888..."
docker run -d \
    --name=heaven-kiosk \
    -p 8888:3000 \
    --shm-size="2gb" \
    --restart unless-stopped \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Kolkata \
    -e TITLE="HeavenOS Workstation" \
    -e CUSTOM_FRAME_RATE=60 \
    -e FRAME_RATE=60 \
    -e WEBTOP_FPS=60 \
    -e MAX_FPS=60 \
    heaven-kiosk

if [ $? -ne 0 ]; then
    echo "ERROR: Container start nahi hua!"
    exit 1
fi

echo ""
echo "======================================================================"
echo "  [✓] HeavenOS is RUNNING on Port 8888!"
echo "======================================================================"
echo ""
echo "1. Public Web Link chalaane ke liye:"
echo "   curl -sL --output cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x cloudflared && ./cloudflared tunnel --url http://localhost:8888"
echo ""
echo "2. Session chalte waqt naya app add/launch karne ke liye (Bina Restart Kiye):"
echo "   bash add_app.sh blender"
echo "   bash add_app.sh discord"
echo "   bash add_app.sh vscode"
echo "======================================================================"
