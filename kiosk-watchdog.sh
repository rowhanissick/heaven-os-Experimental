#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk Mode - App Watchdog & Lock Supervisor
# ====================================================================

echo "[HeavenOS Kiosk] Initializing Locked App Mode..."

# Wait for X server and Openbox to be ready
until xset q &>/dev/null; do
    echo "[HeavenOS Kiosk] Waiting for X display..."
    sleep 1
done

# 1. Apply Openbox locked configuration
mkdir -p /config/.config/openbox
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml
openbox --reconfigure 2>/dev/null || true

# 2. Set Lotus Wallpaper in background
if [ -f /lotus-wallpaper.png ]; then
    feh --bg-fill /lotus-wallpaper.png 2>/dev/null || true
fi

# 3. Background Enforcer: Keep window maximized, active and prevent minimization
(
    while true; do
        sleep 1
        # Find Google Chrome window and force maximized
        CHROME_WIN=$(wmctrl -l | grep -i "chrome" | awk '{print $1}' | head -n 1)
        if [ -n "$CHROME_WIN" ]; then
            wmctrl -i -r "$CHROME_WIN" -b add,maximized_vert,maximized_horz 2>/dev/null || true
            wmctrl -i -a "$CHROME_WIN" 2>/dev/null || true
        fi
    done
) &

# 4. Foreground Watchdog: Launch target app and auto-respawn if closed
APP_TARGET="${APP_MODE:-chrome}"
echo "[HeavenOS Kiosk] Running Locked Application: $APP_TARGET"

while true; do
    case "$APP_TARGET" in
        chrome|google-chrome)
            echo "[HeavenOS Kiosk] Launching Google Chrome..."
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
                https://www.google.com
            ;;
        discord)
            echo "[HeavenOS Kiosk] Launching Discord..."
            discord --no-sandbox --start-maximized
            ;;
        *)
            echo "[HeavenOS Kiosk] Unknown app '$APP_TARGET', defaulting to Google Chrome..."
            google-chrome \
                --no-sandbox \
                --test-type \
                --disable-gpu-sandbox \
                --no-first-run \
                --no-default-browser-check \
                --disable-session-crashed-bubble \
                --disable-infobars \
                --start-maximized \
                https://www.google.com
            ;;
    esac

    echo "[HeavenOS Kiosk] App exited or closed! Auto-restarting in 1 second..."
    sleep 1
done
