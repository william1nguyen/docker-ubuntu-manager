#!/bin/bash

# Function to cleanup on exit
cleanup() {
    echo "Stopping services..."
    vncserver -kill :1 2>/dev/null || true
    pkill -f websockify 2>/dev/null || true
    service ssh stop
    exit 0
}

# Handle signals for graceful shutdown
trap cleanup SIGTERM SIGINT

echo "Starting services..."

# Create temp directories for Chrome
mkdir -p /tmp/chrome-crash-reports /tmp/chrome-user-data
chmod 777 /tmp/chrome-crash-reports /tmp/chrome-user-data

# Start services quietly
service ssh start > /dev/null 2>&1
service dbus start > /dev/null 2>&1

sleep 2

# Start VNC server
echo "Starting VNC server..."
export USER=root
export HOME=/root
vncserver :1 -geometry 1920x1080 -depth 24 > /dev/null 2>&1

sleep 3

# Start noVNC web interface
echo "Starting noVNC web interface..."
websockify --web=/usr/share/novnc/ 6080 localhost:5901 > /dev/null 2>&1 &

sleep 2

# Show connection info
echo "==========================================="
echo "🚀 Container is ready!"
echo ""
echo "🔑 Credentials:"
echo "   Username: root"
echo "   Password: rootpassword"
echo ""
echo "🌐 Access Methods:"
echo "   SSH: ssh root@localhost -p 2222"
echo "   VNC Client: localhost:5901"
echo "   Web VNC: http://localhost:6080/vnc.html"
echo ""
echo "🖥️ Launch Chrome in VNC:"
echo "   Method 1: Double-click Chrome icon on desktop"
echo "   Method 2: Run '/root/start-chrome.sh' in terminal"
echo ""
echo "ℹ️  Chrome errors are suppressed for clean output"
echo "==========================================="

# Keep container running with health check
while true; do
    sleep 30
    if ! pgrep -f "vncserver" > /dev/null; then
        echo "VNC server stopped, restarting..."
        vncserver :1 -geometry 1920x1080 -depth 24 > /dev/null 2>&1
    fi
done