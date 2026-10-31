#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk - Container Init Script
# ====================================================================

mkdir -p /config/.config/openbox
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml

# Configure openbox autostart
mkdir -p /etc/xdg/openbox
cat > /etc/xdg/openbox/autostart << 'EOF'
#!/bin/bash
/usr/local/bin/kiosk-watchdog.sh &
EOF
chmod +x /etc/xdg/openbox/autostart

rm -f /tmp/kiosk-watchdog.pid 2>/dev/null || true
chown -R 1000:1000 /config/.config/openbox 2>/dev/null || true
