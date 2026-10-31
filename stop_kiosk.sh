#!/bin/bash
# ====================================================================
#  HeavenOS Kiosk - Stop & Cleanup Script
# ====================================================================

echo "[→] Stopping HeavenOS Kiosk container..."
docker rm -f heaven-kiosk 2>/dev/null || true
pkill -f cloudflared 2>/dev/null || true

echo "[✓] HeavenOS Kiosk stopped and cleaned up!"
