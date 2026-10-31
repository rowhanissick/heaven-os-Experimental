#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk - Single App Mode Launcher (60 FPS Mode)
# ====================================================================

echo ""
echo "======================================================================"
echo "      HeavenOS KIOSK - Single App Mode (Google Chrome Locked)"
echo "======================================================================"
echo ""

# ---- STEP 1: Check Docker ------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe jao."
    exit 1
fi

# ---- STEP 2: Build Image -------------------------------------------
echo "[→] Cleaning old kiosk containers..."
docker rm -f heaven-kiosk 2>/dev/null || true
docker rmi heaven-kiosk 2>/dev/null || true

echo "[→] Building HeavenOS Kiosk image..."
export DOCKER_BUILDKIT=1
docker build -t heaven-kiosk .
if [ $? -ne 0 ]; then
    echo "ERROR: Docker build fail ho gaya! Check disk space with 'df -h'."
    exit 1
fi
echo "[✓] Image ready!"

echo ""

# ---- STEP 3: Container Run (60 FPS Performance Mode) ---------------
echo "[→] HeavenOS Kiosk container start ho raha hai..."

docker run -d \
    --name=heaven-kiosk \
    -p 8888:3000 \
    --shm-size="2gb" \
    --restart unless-stopped \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Kolkata \
    -e TITLE="HeavenOS - Chrome Kiosk" \
    -e APP_MODE=chrome \
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
echo "  [✓] HeavenOS Kiosk Container Started Successfully on Port 8888!"
echo "======================================================================"
echo ""
echo "To get public web link via Cloudflare Tunnel, run this command:"
echo ""
echo "  curl -sL --output cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x cloudflared && ./cloudflared tunnel --url http://localhost:8888"
echo ""
echo "======================================================================"
