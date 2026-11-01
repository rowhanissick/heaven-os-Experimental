#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk - Multi-App & Single-App On-Demand Launcher
#  Usage Examples:
#    Single App:
#      bash start_kiosk.sh blender
#      bash start_kiosk.sh chrome
#    Dual / Multi Apps (with Ctrl+Tab switching):
#      bash start_kiosk.sh blender chrome
#      bash start_kiosk.sh chrome discord
#      bash start_kiosk.sh vscode chrome
# ====================================================================

# Default to chrome if no args passed
if [ $# -eq 0 ]; then
    APPS=("chrome")
else
    APPS=("$@")
fi

# Convert all args to lowercase
CLEAN_APPS=()
for a in "${APPS[@]}"; do
    LOWER=$(echo "$a" | tr '[:upper:]' '[:lower:]')
    case "$LOWER" in
        blender|blender3d) CLEAN_APPS+=("blender") ;;
        chrome|google-chrome) CLEAN_APPS+=("chrome") ;;
        discord) CLEAN_APPS+=("discord") ;;
        vscode|code) CLEAN_APPS+=("vscode") ;;
        gimp) CLEAN_APPS+=("gimp") ;;
        krita) CLEAN_APPS+=("krita") ;;
        kdenlive) CLEAN_APPS+=("kdenlive") ;;
        vlc) CLEAN_APPS+=("vlc") ;;
        audacity) CLEAN_APPS+=("audacity") ;;
        filezilla) CLEAN_APPS+=("filezilla") ;;
        *) CLEAN_APPS+=("$LOWER") ;;
    esac
done

# Space-separated list of apps (for Docker ARG & ENV)
APP_LIST="${CLEAN_APPS[*]}"

# Tag name joined with dash (e.g. heaven-kiosk:blender-chrome)
TAG_NAME=$(echo "$APP_LIST" | tr ' ' '-')
IMAGE_NAME="heaven-kiosk:${TAG_NAME}"

echo ""
echo "======================================================================"
echo "    HeavenOS KIOSK - Locked Multi-App Environment"
echo "    Active Apps : [ $APP_LIST ]"
echo "    App Switcher: Press Ctrl + Tab (or Alt + Tab) to switch apps"
echo "======================================================================"
echo ""

# ---- STEP 1: Check Docker ------------------------------------------
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker nahi mila! Google Cloud Shell pe jao."
    exit 1
fi

# ---- STEP 2: Build Image ONLY if not already present ---------------
if [[ "$(docker images -q ${IMAGE_NAME} 2> /dev/null)" == "" ]]; then
    echo "[→] Building on-demand image for [ $APP_LIST ]..."
    echo "    (Downloads ONLY the specified apps, zero extras!)"
    export DOCKER_BUILDKIT=1
    docker build --build-arg TARGET_APP="${APP_LIST}" -t "${IMAGE_NAME}" .
    if [ $? -ne 0 ]; then
        echo "ERROR: Build fail ho gaya! Check disk space with 'df -h'."
        exit 1
    fi
    echo "[✓] Image ${IMAGE_NAME} ready!"
else
    echo "[✓] Image ${IMAGE_NAME} already exists! Skipping build for instant start."
fi

# ---- STEP 3: Stop old container if running -------------------------
echo "[→] Stopping previous session if any..."
docker rm -f heaven-kiosk 2>/dev/null || true

# ---- STEP 4: Container Run (60 FPS Performance Mode) ---------------
echo "[→] Launching locked session with [ $APP_LIST ]..."

docker run -d \
    --name=heaven-kiosk \
    -p 8888:3000 \
    --shm-size="2gb" \
    --restart unless-stopped \
    -e PUID=1000 \
    -e PGID=1000 \
    -e TZ=Asia/Kolkata \
    -e TITLE="HeavenOS - $APP_LIST" \
    -e APP_MODE="$APP_LIST" \
    -e CUSTOM_FRAME_RATE=60 \
    -e FRAME_RATE=60 \
    -e WEBTOP_FPS=60 \
    -e MAX_FPS=60 \
    "${IMAGE_NAME}"

if [ $? -ne 0 ]; then
    echo "ERROR: Container start nahi hua!"
    exit 1
fi

echo ""
echo "======================================================================"
echo "  [✓] Session is RUNNING on Port 8888!"
echo "  [★] Tip: User can press 'Ctrl + Tab' to switch between $APP_LIST"
echo "======================================================================"
echo ""
echo "To get public web link via Cloudflare Tunnel, run:"
echo ""
echo "  curl -sL --output cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && chmod +x cloudflared && ./cloudflared tunnel --url http://localhost:8888"
echo ""
echo "======================================================================"
