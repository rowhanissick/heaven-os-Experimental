# ====================================================================
#  HeavenOS Kiosk Mode - Single App Streaming Container
#  Target: Google Chrome (Locked Down Fullscreen Mode)
# ====================================================================

FROM lscr.io/linuxserver/webtop:ubuntu-openbox

LABEL maintainer="HeavenOS"
LABEL description="HeavenOS Single-App Locked Kiosk (Google Chrome)"
LABEL version="1.0"

ENV PUID=1000
ENV PGID=1000
ENV TZ=Asia/Kolkata
ENV TITLE="HeavenOS - Google Chrome"
ENV DEBIAN_FRONTEND=noninteractive
ENV FRAME_RATE=60
ENV CUSTOM_FRAME_RATE=60
ENV WEBTOP_FPS=60
ENV MAX_FPS=60
ENV GALLIUM_DRIVER=llvmpipe
ENV LP_NUM_THREADS=4
ENV APP_MODE=chrome

EXPOSE 3000

# Install dependencies, Google Chrome & X11 lock tools
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        software-properties-common ca-certificates curl wget gnupg \
        feh wmctrl xdotool x11-utils x11-xserver-utils \
        fonts-liberation fonts-noto-color-emoji \
        libu2f-udev libvulkan1 xdg-utils libnspr4 libnss3 \
        pulseaudio-utils alsa-utils && \
    mkdir -p /tmp/downloads && \
    wget -q -O /tmp/downloads/google-chrome-stable.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    (dpkg -i /tmp/downloads/google-chrome-stable.deb 2>/dev/null || apt-get install -fy) && \
    rm -rf /tmp/downloads /var/lib/apt/lists/* /var/tmp/* /tmp/* && \
    apt-get clean

# Copy wallpaper
COPY Lotus-Wallpaper-Upscaled16x.png /lotus-wallpaper.png

# Copy Openbox locked configuration
COPY openbox-rc.xml /etc/openbox/locked-rc.xml

# Copy App Watchdog supervisor script
COPY kiosk-watchdog.sh /usr/local/bin/kiosk-watchdog.sh
RUN chmod +x /usr/local/bin/kiosk-watchdog.sh

# Copy container init script
COPY init-kiosk.sh /custom-cont-init.d/99-heaven-kiosk.sh
RUN chmod +x /custom-cont-init.d/99-heaven-kiosk.sh
