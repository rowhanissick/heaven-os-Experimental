#!/bin/bash
# ====================================================================
#  HeavenOS - Dynamic Hot In-Session App Installer
#  Installs and launches apps into the ACTIVE session without stopping!
#  Usage:
#    install-app blender
#    install-app discord
#    install-app vscode
#    install-app gimp
#    install-app krita
#    install-app vlc
#    install-app audacity
# ====================================================================

APP_INPUT="$1"
APP=$(echo "$APP_INPUT" | tr '[:upper:]' '[:lower:]')

if [ -z "$APP" ]; then
    echo "ERROR: Please specify an app to install! (e.g. install-app blender)"
    exit 1
fi

echo "[HeavenOS] Live Installing '${APP}' into active session..."

# Find the active X11 display (usually :1 in Webtop)
TARGET_DISP="${DISPLAY:-:1}"

case "$APP" in
    blender|blender3d)
        if ! command -v blender &>/dev/null; then
            echo "[→] Downloading & Installing Blender 3D..."
            apt-get update && apt-get install -y --no-install-recommends blender
        fi
        echo "[✓] Launching Blender 3D on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} blender" &
        ;;
    discord)
        if ! command -v discord &>/dev/null; then
            echo "[→] Downloading & Installing Discord..."
            mkdir -p /tmp/pkg
            curl -sSL -o /tmp/pkg/discord.deb "https://discord.com/api/download?platform=linux&format=deb"
            dpkg -i /tmp/pkg/discord.deb 2>/dev/null || apt-get install -fy
            rm -rf /tmp/pkg
        fi
        echo "[✓] Launching Discord on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} discord --no-sandbox" &
        ;;
    vscode|code)
        if ! command -v code &>/dev/null; then
            echo "[→] Downloading & Installing VS Code..."
            wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg
            echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list
            apt-get update && apt-get install -y --no-install-recommends code
        fi
        echo "[✓] Launching VS Code on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} code --no-sandbox --user-data-dir=/config/.vscode-oss" &
        ;;
    gimp)
        if ! command -v gimp &>/dev/null; then
            echo "[→] Downloading & Installing GIMP..."
            apt-get update && apt-get install -y --no-install-recommends gimp
        fi
        echo "[✓] Launching GIMP on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} gimp" &
        ;;
    krita)
        if ! command -v krita &>/dev/null; then
            echo "[→] Downloading & Installing Krita..."
            apt-get update && apt-get install -y --no-install-recommends krita
        fi
        echo "[✓] Launching Krita on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} krita" &
        ;;
    vlc)
        if ! command -v vlc &>/dev/null; then
            echo "[→] Downloading & Installing VLC..."
            apt-get update && apt-get install -y --no-install-recommends vlc
        fi
        echo "[✓] Launching VLC on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} vlc" &
        ;;
    audacity)
        if ! command -v audacity &>/dev/null; then
            echo "[→] Downloading & Installing Audacity..."
            apt-get update && apt-get install -y --no-install-recommends audacity
        fi
        echo "[✓] Launching Audacity on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} audacity" &
        ;;
    chrome|google-chrome)
        echo "[✓] Launching Google Chrome on display ${TARGET_DISP}..."
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} google-chrome --no-sandbox --test-type --disable-gpu-sandbox 'https://www.google.com'" &
        ;;
    *)
        echo "[→] Attempting to install generic package '$APP'..."
        apt-get update && apt-get install -y --no-install-recommends "$APP"
        env DISPLAY="${TARGET_DISP}" su - abc -c "DISPLAY=${TARGET_DISP} $APP" &
        ;;
esac

echo "======================================================================"
echo "  [✓] Successfully installed and pushed to user's live desktop!"
echo "======================================================================"
