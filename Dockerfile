# ====================================================================
#  HeavenOS Kiosk Mode - Multi-App & Single-App On-Demand Container
#  Installs ONLY the apps passed in TARGET_APP (e.g. "blender chrome")
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-openbox

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS Multi-App Locked Kiosk with Smart Window Guard"
LABEL version="5.0"

# Target apps argument (e.g. "blender" or "blender chrome")
ARG TARGET_APP=chrome

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE="HeavenOS"
ENV DEBIAN_FRONTEND=noninteractive
ENV FRAME_RATE=60
ENV CUSTOM_FRAME_RATE=60
ENV WEBTOP_FPS=60
ENV MAX_FPS=60
ENV GALLIUM_DRIVER=llvmpipe
ENV LP_NUM_THREADS=4
ENV APP_MODE=${TARGET_APP}

EXPOSE 3000

# 1. Base Setup: Essential X11 tools, sound & lock packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates curl wget gnupg \
        feh wmctrl xdotool x11-utils x11-xserver-utils \
        fonts-liberation fonts-noto-color-emoji \
        libu2f-udev libvulkan1 xdg-utils libnspr4 libnss3 \
        pulseaudio-utils alsa-utils zenity && \
    apt-get clean

# 2. On-Demand App Installer: Loops through TARGET_APP and installs ONLY requested apps
RUN mkdir -p /tmp/downloads && \
    for APP in ${TARGET_APP}; do \
        case "$APP" in \
            blender|blender3d) \
                echo "[HeavenOS] Installing Blender 3D..." && \
                apt-get update && apt-get install -y --no-install-recommends blender ;; \
            discord) \
                echo "[HeavenOS] Installing Discord..." && \
                curl -sSL -o /tmp/downloads/discord.deb "https://discord.com/api/download?platform=linux&format=deb" && \
                (dpkg -i /tmp/downloads/discord.deb 2>/dev/null || apt-get install -fy) ;; \
            vscode|code) \
                echo "[HeavenOS] Installing VS Code..." && \
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/packages.microsoft.gpg && \
                echo "deb [arch=amd64 signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list && \
                apt-get update && apt-get install -y --no-install-recommends code ;; \
            gimp) \
                echo "[HeavenOS] Installing GIMP..." && \
                apt-get update && apt-get install -y --no-install-recommends gimp ;; \
            krita) \
                echo "[HeavenOS] Installing Krita..." && \
                apt-get update && apt-get install -y --no-install-recommends krita ;; \
            kdenlive) \
                echo "[HeavenOS] Installing Kdenlive..." && \
                apt-get update && apt-get install -y --no-install-recommends kdenlive ;; \
            vlc) \
                echo "[HeavenOS] Installing VLC..." && \
                apt-get update && apt-get install -y --no-install-recommends vlc ;; \
            audacity) \
                echo "[HeavenOS] Installing Audacity..." && \
                apt-get update && apt-get install -y --no-install-recommends audacity ;; \
            filezilla) \
                echo "[HeavenOS] Installing FileZilla..." && \
                apt-get update && apt-get install -y --no-install-recommends filezilla ;; \
            chrome|google-chrome) \
                echo "[HeavenOS] Installing Google Chrome..." && \
                wget -q -O /tmp/downloads/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
                (dpkg -i /tmp/downloads/chrome.deb 2>/dev/null || apt-get install -fy) ;; \
        esac ; \
    done && \
    rm -rf /tmp/downloads /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    apt-get clean

# 3. Disable Terminal for normal sessions
RUN chmod 000 /usr/bin/xfce4-terminal /usr/bin/xterm /usr/bin/uxterm 2>/dev/null || true

# Copy Lotus wallpaper
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# Copy Openbox locked configuration (With Smart Minimize & No Desktop access)
COPY openbox-rc.xml /etc/openbox/locked-rc.xml

# Copy App Watchdog supervisor script
COPY kiosk-watchdog.sh /usr/local/bin/kiosk-watchdog.sh
RUN chmod +x /usr/local/bin/kiosk-watchdog.sh

# Copy container init script
COPY init-kiosk.sh /custom-cont-init.d/99-heaven-kiosk.sh
RUN chmod +x /custom-cont-init.d/99-heaven-kiosk.sh
