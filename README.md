# ROS2 VNC Desktop for Eurobot 2026 Navigation

## 🎯 Purpose

This environment is designed to:

- Let you run **RViz2 / ROS 2 GUI inside Docker** and view it from **macOS (including Apple Silicon)** via **VNC**.  
- Avoid dealing with XQuartz or complex X11 forwarding. You just connect to `localhost:5901` and use the terminal inside the container to run `sim` and other commands.

Typical use cases:

- Testing / demo of the Eurobot 2026 navigation system  
- Running RViz2 on a Mac to visualize paths and debug Nav2

---

## 🔧 Features

### 🖥 VNC-based ROS2 GUI

- Base image: `osrf/ros:humble-desktop` (includes RViz2)
- Runs `tigervnc-standalone-server` inside the container
- Automatically creates `~/.vnc/passwd` and `~/.vnc/xstartup`
- Starts a single `xterm` in the VNC session; from there you can run:
  - `sim` → `ros2 launch navigation2_run sim_launch.py`
  - Any other ROS 2 commands

### 🐋 Docker + Compose

- `Dockerfile` builds the VNC-enabled ROS 2 image
- `docker-compose.yaml`:
  - Exposes VNC port `5901` to the host (`0.0.0.0:5901->5901`)
  - Forces platform `linux/amd64` so it works on Apple Silicon
  - Mounts your Eurobot workspace into the container

### 🧩 Integration with Eurobot 2026 Navigation

Inside the container, `.bashrc` will:

- `source /opt/ros/humble/setup.bash`
- `source ~/Eurobot-2026-Navigation-ws/Eurobot-2026-Navigation2/install/setup.bash`
- Provide useful aliases:
  - `sim` → `ros2 launch navigation2_run sim_launch.py`
  - `object` → `ros2 run object_layer ObjectSim`
  - `rival` → `ros2 run object_layer ObjectSim`
- Set a colored prompt with hostname shown as `docker-desktop`

---

## 🧱 Concept / Architecture

High-level structure:

- **macOS Host**
  - Runs Docker Desktop
  - Runs your VNC viewer (RealVNC / TigerVNC etc.)

- **`ros2-vnc` Container**
  - Base: Ubuntu + ROS 2 Humble Desktop
  - Runs `vncserver :1`
  - `start-vnc.sh` creates `~/.vnc/xstartup`, starts `xterm` and keeps the session alive
  - Mounts your Eurobot workspace:
    - Host: `~/Eurobot-2026-Navigation-ws`
    - Container: `/home/user/Eurobot-2026-Navigation-ws`

- **VNC**
  - Exposes port `5901` to the host
  - You connect to `127.0.0.1:5901` from macOS
  - The VNC window shows the container’s X session (with `xterm` and later RViz2)

---

## ⚙️ How to Use

### 1. Directory Layout

Assumed layout:

```bash
~/Desktop/VNC/docker
├── Dockerfile
├── docker-compose.yaml
└── start-vnc.sh

~/Eurobot-2026-Navigation-ws
└── Eurobot-2026-Navigation2
    ├── src/...
    └── install/...

### 2. Build the image and start the container
```
cd ~/VNC/docker
docker compose build
docker compose up
```
You should see something like that
```
ros2-vnc  | New Xtigervnc server 'xxxxxx:1 (user)' on port 5901 for display :1.
```
That means the VNC server is running.

### 3. Connect with a VNC Client
On macOS:
- Open a VNC client (RealVNC, TigerVNC, etc.)
- Connect to: localhost:5901
- Password: ros (or the value you set in VNC_PASSWORD)
After connecting, you will see an xterm window. That terminal is inside the container.

### 4. Run Eurobot Navigation from VNC xterm
```
docker exec -it ros2-vnc bash
cd ~/Eurobot-2026-Navigation-ws/Eurobot-2026-Navigation2
source /opt/ros/humble/setup.bash
source install/setup.bash
sim

# or using
# ros2 launch navigation2_run sim_launch.py
```

## 🧑‍💻 For Your Own Use: What to Modify
### 1. Volume Path in docker-compose.yaml
```
services:
  ros2-vnc:
    build: .
    container_name: ros2-vnc
    platform: linux/amd64
    ports:
      - "5901:5901"
    volumes:
      - ~/Eurobot-2026-Navigation-ws:/home/user/Eurobot-2026-Navigation-ws # TODO: adjust to your workspace path
```
If your workspace is in a different directory, update this path.

### 2. Workspace Path in .bashrc (Inside Container)

### 3. VNC Password
In docker-compose.yaml or Dockerfile environment:
```
environment:
  - VNC_PASSWORD=ros
```
Change this if you want a different password, and document it.

## 🧹 Clean Rebuild
If something is broken and you want a clean rebuild:
```
# Stop and remove the container
docker compose down

# Rebuild without cache
docker compose build --no-cache

# Start again
docker compose up
```

## 📝 Summary
- This VNC container exists purely to give ROS 2 / RViz2 a GUI desktop inside Docker.
- Core navigation logic still runs in the same container as usual.
- To adapt it for your own environment, adjust:
  - Volume path in docker-compose.yaml
  - Workspace path and aliases in .bashrc
  - VNC password and prompt if needed

Once that is set, your workflow is:
docker compose up → VNC to localhost:5901 → use the xterm to run sim and other ROS commands.