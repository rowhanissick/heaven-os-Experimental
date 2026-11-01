#!/bin/bash
# ====================================================================
#  HeavenOS - Desktop Session Supervisor (Sandboxed UI)
#  - Normal window minimize / maximize / close
#  - Sleek Tint2 taskbar dock
#  - Desktop right-click disabled
#  - Terminal blocked
# ====================================================================

echo "[HeavenOS] Initializing Desktop Environment..."

# Wait for X server
until xset q &>/dev/null; do
    sleep 1
done

# 1. Apply Openbox configuration
mkdir -p /config/.config/openbox
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml 2>/dev/null || true
openbox --reconfigure 2>/dev/null || true

# 2. Set Lotus Wallpaper
if [ -f /lotus-wallpaper.png ]; then
    feh --bg-fill /lotus-wallpaper.png 2>/dev/null || true
fi

# 3. Disable Terminal binaries system-wide
chmod 000 /usr/bin/xfce4-terminal /usr/bin/xterm /usr/bin/uxterm 2>/dev/null || true

# 4. Start Tint2 Dock (shows running apps, allows restore on click)
mkdir -p /config/.config/tint2
cp -f /etc/tint2/tint2rc /config/.config/tint2/tint2rc 2>/dev/null || true
killall tint2 2>/dev/null || true
tint2 -c /config/.config/tint2/tint2rc &

# 5. Launch Default App (Google Chrome)
sleep 1
echo "[HeavenOS] Launching default app: Google Chrome..."
google-chrome \
    --no-sandbox \
    --test-type \
    --disable-gpu-sandbox \
    --no-first-run \
    --no-default-browser-check \
    --disable-session-crashed-bubble \
    --disable-infobars \
    --start-maximized \
    "https://www.google.com" &

# Keep container session loop alive
while true; do
    sleep 10
done
