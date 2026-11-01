#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk Mode - Multi-App Watchdog & Anti-Minimize Supervisor
# ====================================================================

PIDFILE="/tmp/kiosk-watchdog.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "[HeavenOS Kiosk] Watchdog already running (PID $(cat "$PIDFILE")). Exiting duplicate."
    exit 0
fi
echo $$ > "$PIDFILE"

echo "[HeavenOS Kiosk] Initializing Locked App Environment..."

# Wait for X display to be ready
until xset q &>/dev/null; do
    echo "[HeavenOS Kiosk] Waiting for X display..."
    sleep 1
done

# 1. Apply Openbox locked configuration with Ctrl+Tab Switcher
mkdir -p /config/.config/openbox
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml 2>/dev/null || true
openbox --reconfigure 2>/dev/null || true

# 2. Set Lotus Wallpaper in background
if [ -f /lotus-wallpaper.png ]; then
    feh --bg-fill /lotus-wallpaper.png 2>/dev/null || true
fi

# 3. Background Enforcer: Anti-Minimize & Keep Windows Maximized
(
    while true; do
        sleep 0.5
        ALL_WINS=$(wmctrl -l | awk '{print $1}')
        for WID in $ALL_WINS; do
            # Un-hide (un-minimize) if user clicked minimize (_)
            wmctrl -i -r "$WID" -b remove,hidden 2>/dev/null || true
            # Force maximize
            wmctrl -i -r "$WID" -b add,maximized_vert,maximized_horz 2>/dev/null || true
        done
    done
) &

# Normalize APP_MODE list (can contain 1 or multiple apps, e.g. "blender chrome")
ALLOWED_APPS=$(echo "${APP_MODE:-chrome}" | tr '[:upper:]' '[:lower:]')
echo "[HeavenOS Kiosk] Allowed Applications in this session: $ALLOWED_APPS"

# Function to launch an individual app if not already running
launch_app_if_needed() {
    local APP="$1"
    case "$APP" in
        blender|blender3d)
            if ! pgrep -x "blender" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting Blender 3D..."
                blender &
                sleep 2
            fi
            ;;
        discord)
            if ! pgrep -f "discord" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting Discord..."
                discord --no-sandbox --start-maximized &
                sleep 2
            fi
            ;;
        vscode|code)
            if ! pgrep -f "code" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting VS Code..."
                code --no-sandbox --user-data-dir=/config/.vscode-oss --no-first-run &
                sleep 2
            fi
            ;;
        gimp)
            if ! pgrep -x "gimp" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting GIMP..."
                gimp &
                sleep 2
            fi
            ;;
        krita)
            if ! pgrep -x "krita" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting Krita..."
                krita --nosplash &
                sleep 2
            fi
            ;;
        kdenlive)
            if ! pgrep -x "kdenlive" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting Kdenlive..."
                kdenlive &
                sleep 2
            fi
            ;;
        vlc)
            if ! pgrep -x "vlc" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting VLC Player..."
                vlc --no-video-title-show &
                sleep 2
            fi
            ;;
        audacity)
            if ! pgrep -x "audacity" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting Audacity..."
                audacity &
                sleep 2
            fi
            ;;
        filezilla)
            if ! pgrep -x "filezilla" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting FileZilla..."
                filezilla &
                sleep 2
            fi
            ;;
        chrome|google-chrome)
            if ! pgrep -f "chrome" > /dev/null; then
                echo "[HeavenOS Kiosk] Starting Google Chrome..."
                google-chrome \
                    --no-sandbox \
                    --test-type \
                    --disable-gpu-sandbox \
                    --no-first-run \
                    --no-default-browser-check \
                    --disable-session-crashed-bubble \
                    --disable-infobars \
                    --start-maximized \
                    --window-position=0,0 \
                    "https://www.google.com" &
                sleep 2
            fi
            ;;
    esac
}

# 4. Watchdog Loop: Keep all allowed apps alive simultaneously
while true; do
    for APP in $ALLOWED_APPS; do
        launch_app_if_needed "$APP"
    done
    sleep 2
done
