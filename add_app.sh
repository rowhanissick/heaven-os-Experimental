#!/bin/bash
# ====================================================================
#  HeavenOS - Helper to Add App to Active Running Session
#  Usage from Cloud Shell terminal:
#    bash add_app.sh blender
#    bash add_app.sh discord
#    bash add_app.sh vscode
# ====================================================================

APP="$1"

if [ -z "$APP" ]; then
    echo "Usage: bash add_app.sh <app_name>"
    echo "Examples:"
    echo "  bash add_app.sh blender"
    echo "  bash add_app.sh discord"
    echo "  bash add_app.sh vscode"
    exit 1
fi

echo "[→] Requesting active HeavenOS session to install & launch '$APP'..."
docker exec heaven-kiosk install-app "$APP"
