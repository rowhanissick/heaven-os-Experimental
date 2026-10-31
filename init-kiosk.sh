#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk - Container Init Script
# ====================================================================

mkdir -p /config/.config/openbox
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml

# Configure openbox autostart to trigger our kiosk-watchdog
cat > /config/.config/openbox/autostart << 'EOF'
#!/bin/bash
/usr/local/bin/kiosk-watchdog.sh &
EOF
chmod +x /config/.config/openbox/autostart

# Also register in system-wide openbox autostart
mkdir -p /etc/xdg/openbox
cat > /etc/xdg/openbox/autostart << 'EOF'
#!/bin/bash
/usr/local/bin/kiosk-watchdog.sh &
EOF
chmod +x /etc/xdg/openbox/autostart

chown -R 1000:1000 /config/.config/openbox 2>/dev/null || true
