#!/bin/bash
# ====================================================================
#  HeavenOS - Container Init Script
# ====================================================================

# Overwrite Openbox rc.xml in ALL possible locations so it's 100% active
mkdir -p /config/.config/openbox /etc/xdg/openbox /defaults
cp -f /etc/openbox/locked-rc.xml /config/.config/openbox/rc.xml
cp -f /etc/openbox/locked-rc.xml /etc/xdg/openbox/rc.xml
cp -f /etc/openbox/locked-rc.xml /defaults/rc.xml

# Configure tint2 directory
mkdir -p /config/.config/tint2 /etc/tint2
cp -f /etc/tint2/tint2rc /config/.config/tint2/tint2rc

# Set autostart
mkdir -p /etc/xdg/openbox
cat > /etc/xdg/openbox/autostart << 'EOF'
#!/bin/bash
/usr/local/bin/session-start.sh &
EOF
chmod +x /etc/xdg/openbox/autostart

chown -R 1000:1000 /config 2>/dev/null || true
