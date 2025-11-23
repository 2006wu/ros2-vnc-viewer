#!/usr/bin/env bash

# 1. 設定 VNC 密碼
mkdir -p "$HOME/.vnc"

: "${VNC_PASSWORD:=ros}"

echo "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"

# 2. xstartup：只開一個 xterm，並用 while true 讓 session 不結束
cat > "$HOME/.vnc/xstartup" << 'EOF'
#!/bin/sh
xrdb "$HOME/.Xresources" 2>/dev/null || true

export DESKTOP_SESSION=xfce
export XDG_CURRENT_DESKTOP=XFCE

# 啟動完整桌面
startxfce4

EOF

chmod +x "$HOME/.vnc/xstartup"

# 3. 有 dbus 就開
if command -v dbus-launch >/dev/null 2>&1; then
  eval "$(dbus-launch --sh-syntax)"
fi

# 4. 啟動 VNC server
vncserver "$DISPLAY" -geometry 1600x900 -localhost no

# 5. 保持 container 活著
sleep infinity
