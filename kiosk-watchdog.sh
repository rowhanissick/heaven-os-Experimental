#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk Mode - App Watchdog & Lock Supervisor
# ====================================================================

# Prevent multiple instances of this watchdog script from running
PIDFILE="/tmp/kiosk-watchdog.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "[HeavenOS Kiosk] Watchdog already running (PID $(cat "$PIDFILE")). Exiting duplicate."
    exit 0
fi
echo $$ > "$PIDFILE"

echo "[HeavenOS Kiosk] Initializing Locked App Mode..."

# Wait for X display to be ready
until xset q &>/dev/null; do
    echo "[HeavenOS Kiosk] Waiting for X display..."
    sleep 1
done

# 1. Apply Openbox locked configuration
mkdir -p /config/.config/openbox
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml 2>/dev/null || true
openbox --reconfigure 2>/dev/null || true

# 2. Set Lotus Wallpaper in background
if [ -f /lotus-wallpaper.png ]; then
    feh --bg-fill /lotus-wallpaper.png 2>/dev/null || true
fi

# 3. Background Enforcer: Anti-Minimize & Keep Chrome permanently Maximized
(
    while true; do
        sleep 0.5
        # Find Google Chrome window ID
        CHROME_WINS=$(wmctrl -l | grep -i "Google Chrome" | awk '{print $1}')
        for WID in $CHROME_WINS; do
            # Un-hide (un-minimize) if user clicked minimize (_)
            wmctrl -i -r "$WID" -b remove,hidden 2>/dev/null || true
            # Force maximize horizontally and vertically
            wmctrl -i -r "$WID" -b add,maximized_vert,maximized_horz 2>/dev/null || true
            # Force focus so it stays in front
            wmctrl -i -a "$WID" 2>/dev/null || true
        done
    done
) &

# 4. Foreground Watchdog: Keep exactly ONE instance of the app alive
APP_TARGET="${APP_MODE:-chrome}"
echo "[HeavenOS Kiosk] Managing Application: $APP_TARGET"

while true; do
    # Check if Chrome is already running
    if ! pgrep -f "chrome" > /dev/null; then
        echo "[HeavenOS Kiosk] Chrome not running. Launching single instance..."
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
        
        # Wait for Chrome to actually start
        sleep 3
    fi

    # Sleep before checking again to avoid tight loops or opening extra tabs
    sleep 2
done
