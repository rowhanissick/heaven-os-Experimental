#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk Mode - Smart "Never-Empty-Desktop" Supervisor
#  Features:
#   - Minimize is ALLOWED on windows
#   - BUT if all windows are minimized, it instantly restores an app
#     so the user NEVER gets access to the desktop!
#   - If user minimizes App 1, App 2 automatically takes the screen.
#   - Terminal is completely disabled for normal users.
# ====================================================================

PIDFILE="/tmp/kiosk-watchdog.pid"
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "[HeavenOS] Watchdog already running. Exiting duplicate."
    exit 0
fi
echo $$ > "$PIDFILE"

echo "[HeavenOS] Initializing Smart Kiosk Supervisor..."

# Wait for X display to be ready
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

# 3. Disable all terminals system-wide
chmod 000 /usr/bin/xfce4-terminal /usr/bin/xterm /usr/bin/uxterm 2>/dev/null || true

ALLOWED_APPS=$(echo "${APP_MODE:-chrome}" | tr '[:upper:]' '[:lower:]')
echo "[HeavenOS] Allowed Applications in session: $ALLOWED_APPS"

# Function to launch an individual app if not already running
launch_app_if_needed() {
    local APP="$1"
    case "$APP" in
        blender|blender3d)
            if ! pgrep -x "blender" > /dev/null; then
                blender &
                sleep 2
            fi
            ;;
        discord)
            if ! pgrep -f "discord" > /dev/null; then
                discord --no-sandbox --start-maximized &
                sleep 2
            fi
            ;;
        vscode|code)
            if ! pgrep -f "code" > /dev/null; then
                code --no-sandbox --user-data-dir=/config/.vscode-oss --no-first-run &
                sleep 2
            fi
            ;;
        gimp)
            if ! pgrep -x "gimp" > /dev/null; then
                gimp &
                sleep 2
            fi
            ;;
        krita)
            if ! pgrep -x "krita" > /dev/null; then
                krita --nosplash &
                sleep 2
            fi
            ;;
        kdenlive)
            if ! pgrep -x "kdenlive" > /dev/null; then
                kdenlive &
                sleep 2
            fi
            ;;
        vlc)
            if ! pgrep -x "vlc" > /dev/null; then
                vlc --no-video-title-show &
                sleep 2
            fi
            ;;
        audacity)
            if ! pgrep -x "audacity" > /dev/null; then
                audacity &
                sleep 2
            fi
            ;;
        filezilla)
            if ! pgrep -x "filezilla" > /dev/null; then
                filezilla &
                sleep 2
            fi
            ;;
        chrome|google-chrome|*)
            if ! pgrep -f "chrome" > /dev/null; then
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

# 4. Background Enforcer: "NEVER EMPTY DESKTOP" Logic
# Checks every 0.3s. If all windows are minimized or hidden,
# it immediately brings one to front so desktop is NEVER visible!
(
    LAST_FOCUSED=""
    while true; do
        sleep 0.3
        
        # Get list of all client window IDs
        WINS=($(wmctrl -l | awk '{print $1}'))
        TOTAL=${#WINS[@]}

        if [ "$TOTAL" -gt 0 ]; then
            VISIBLE_WINS=()
            HIDDEN_WINS=()

            for WID in "${WINS[@]}"; do
                # Check if window is minimized (has _NET_WM_STATE_HIDDEN)
                if xprop -id "$WID" _NET_WM_STATE 2>/dev/null | grep -q "_NET_WM_STATE_HIDDEN"; then
                    HIDDEN_WINS+=("$WID")
                else
                    VISIBLE_WINS+=("$WID")
                fi
            done

            # CATCH: Agar user ne sabhi windows minimize kar diye (VISIBLE == 0):
            # Desktop access bilkul nahi milega! Turant last app ko restore karke samne le aao!
            if [ "${#VISIBLE_WINS[@]}" -eq 0 ]; then
                TARGET_RESTORE="${HIDDEN_WINS[0]}"
                if [ -n "$TARGET_RESTORE" ]; then
                    wmctrl -i -r "$TARGET_RESTORE" -b remove,hidden 2>/dev/null || true
                    wmctrl -i -r "$TARGET_RESTORE" -b add,maximized_vert,maximized_horz 2>/dev/null || true
                    wmctrl -i -a "$TARGET_RESTORE" 2>/dev/null || true
                fi
            elif [ "${#VISIBLE_WINS[@]}" -eq 1 ] && [ "${#HIDDEN_WINS[@]}" -ge 1 ]; then
                # Exactly 1 window visible hai. Ensure it is maximized
                CURRENT="${VISIBLE_WINS[0]}"
                wmctrl -i -r "$CURRENT" -b add,maximized_vert,maximized_horz 2>/dev/null || true
            fi
        fi
    done
) &

# 5. Foreground Watchdog: Keep allowed applications running
while true; do
    for APP in $ALLOWED_APPS; do
        launch_app_if_needed "$APP"
    done
    sleep 2
done
