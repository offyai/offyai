#!/bin/bash

# ========================================
#        OffyAi 0.5B LAUNCHER (Linux)
# ========================================

clear
echo
echo "========================================"
echo "        || OffyAi LAUNCHER ||"
echo "========================================"
echo "         ||  OffyAi 0.5B Model  ||"
echo "========================================"
echo

# =======================================================
# FILE CHECKS
# =======================================================
echo "[CHECK] Verifying required files..."
echo

if [[ ! -f "src/llama-server" ]]; then
    echo "[ERROR] llama-server not found in src/"
    read -p "Press ENTER to exit..."
    exit 1
fi

if [[ ! -f "models/OffyAi-0.5B.gguf" ]]; then
    echo "[ERROR] Model 'OffyAi-0.5B.gguf' not found in models/"
    read -p "Press ENTER to exit..."
    exit 1
fi

echo "[SUCCESS] All required files verified!"
echo

# =======================================================
# START SERVER
# =======================================================
echo "========================================"
echo "        STARTING SERVER..."
echo "========================================"
echo

src/llama-server \
    -m models/OffyAi-0.5B.gguf \
    -c 1024 \
    -ngl 0 \
    --port 8080 &

SERVER_PID=$!

echo "[INFO] Server PID: $SERVER_PID"
echo
echo "[INFO] Waiting for server to start..."
sleep 3

# =======================================================
# BROWSER AUTO-LAUNCH
# =======================================================

URL="http://localhost:8080"

echo
echo "========================================"
echo "      LAUNCHING WEB INTERFACE"
echo "========================================"
echo

# Browser function
open_browser() {
    local cmd="$1"
    echo "[ACTION] Trying: $cmd"
    $cmd "$URL" >/dev/null 2>&1
    return $?
}

# Try multiple open methods
if open_browser "xdg-open"; then
    echo "[SUCCESS] Browser opened via xdg-open"

elif open_browser "gio open"; then
    echo "[SUCCESS] Browser opened via gio"

elif open_browser "gnome-open"; then
    echo "[SUCCESS] Browser opened via gnome-open"

elif open_browser "sensible-browser"; then
    echo "[SUCCESS] Browser opened via sensible-browser"

elif command -v firefox >/dev/null; then
    firefox "$URL" >/dev/null 2>&1 &
    echo "[SUCCESS] Browser opened via Firefox"

elif command -v google-chrome >/dev/null; then
    google-chrome "$URL" >/dev/null 2>&1 &
    echo "[SUCCESS] Browser opened via Chrome"

elif command -v chromium >/dev/null; then
    chromium "$URL" >/dev/null 2>&1 &
    echo "[SUCCESS] Browser opened via Chromium"

else
    echo "[WARN] Could NOT auto-launch browser!"
    echo "[INFO] Open manually: $URL"
fi

# =======================================================
# SHUTDOWN HANDLER
# =======================================================

shutdown() {
    echo
    echo "========================================"
    echo "       INITIATING SHUTDOWN..."
    echo "========================================"
    echo
    kill $SERVER_PID >/dev/null 2>&1
    echo "[SUCCESS] Server stopped!"
    exit 0
}

trap shutdown INT

# Keep script alive for logs
while true; do
    sleep 1
done
