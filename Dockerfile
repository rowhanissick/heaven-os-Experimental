# ====================================================================
#  HeavenOS - Lightweight Sandboxed Workstation
#  - Default App: Google Chrome ONLY
#  - Dynamic Hot-Install supported via: install-app <name>
#  - Terminal: Disabled
#  - Desktop Right-Click: Disabled
#  - Taskbar / Dock: Tint2 (Restores minimized windows)
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-openbox

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS Sandboxed Desktop with Dynamic Hot-Installer"
LABEL version="6.0"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE="HeavenOS Workstation"
ENV DEBIAN_FRONTEND=noninteractive
ENV FRAME_RATE=60
ENV CUSTOM_FRAME_RATE=60
ENV WEBTOP_FPS=60
ENV MAX_FPS=60
ENV GALLIUM_DRIVER=llvmpipe
ENV LP_NUM_THREADS=4

EXPOSE 3000

# 1. Base Tools, Tint2 Dock, Google Chrome ONLY
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates curl wget gnupg sudo \
        tint2 feh wmctrl xdotool x11-utils x11-xserver-utils \
        fonts-liberation fonts-noto-color-emoji \
        libu2f-udev libvulkan1 xdg-utils libnspr4 libnss3 \
        pulseaudio-utils alsa-utils zenity && \
    mkdir -p /tmp/downloads && \
    wget -q -O /tmp/downloads/chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    (dpkg -i /tmp/downloads/chrome.deb 2>/dev/null || apt-get install -fy) && \
    rm -rf /tmp/downloads /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    apt-get clean

# 2. Disable Terminal for normal sessions
RUN chmod 000 /usr/bin/xfce4-terminal /usr/bin/xterm /usr/bin/uxterm 2>/dev/null || true

# 3. Allow abc user to run sudo apt-get without password for dynamic installs
RUN echo "abc ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# 4. Copy Assets and Configurations
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png
COPY tint2rc /etc/tint2/tint2rc
COPY openbox-rc.xml /etc/openbox/locked-rc.xml

# 5. Copy Hot-Installer & Session Start scripts
COPY install-app.sh /usr/local/bin/install-app
RUN chmod +x /usr/local/bin/install-app

COPY session-start.sh /usr/local/bin/session-start.sh
RUN chmod +x /usr/local/bin/session-start.sh

COPY init-kiosk.sh /custom-cont-init.d/99-heaven-init.sh
RUN chmod +x /custom-cont-init.d/99-heaven-init.sh
