# Docker Ubuntu Manager

Fast setup for an Ubuntu server with Docker, including SSH access, persistent data, OpenVPN configuration, and optional GUI mode.

---

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Docker Compose Workflow](#docker-compose-workflow)
4. [SSH Access](#ssh-access)
5. [GUI Mode (--gui)](#gui-mode---gui)
6. [OpenVPN Management](#openvpn-management)
7. [Apply VPN Config to a Container](#apply-vpn-config-to-a-container)
8. [Verifying VPN Connection](#verifying-vpn-connection)
9. [Apply Push Routes on OpenVPN Server](#apply-push-routes-on-openvpn-server)
10. [Notes](#notes)
11. [TODO](#todo)

---

## Features

- Quick setup of Ubuntu server containers
- Persistent data storage
- Integrated OpenVPN server with client management
- Private and external network configuration for lab isolation
- **Optional GUI desktop with Chrome browser via VNC/noVNC**

---

## Prerequisites

Ensure your Docker environment is ready:

- Docker and Docker Compose installed
- Basic understanding of container networking

> ⚠️ **Note:** Orbstack does not support isolated networks, which is not suitable for this lab setup.
> It is recommended to use standard Docker: [Orbstack issue #1944](https://github.com/orbstack/orbstack/issues/1944)

---

## Docker Compose Workflow

The Makefile provides the following targets:

### Start Lab

```bash
# Normal mode
make start

# VPN mode (vpn)
make start mode=vpn

# GUI mode (--gui)
make start --gui
```

This will start all containers defined in:

- Normal: `deployments/ubuntu/server/docker-compose.yml`
- VPN: `deployments/vpn/docker-compose.yml`
- GUI: `deployments/ubuntu/gui/docker-compose.yml`

---

### Reset Lab

```bash
make reset
```

This cleans up:

- Networks
- Containers
- Volumes
- Images

---

### List OpenVPN Profiles

```bash
make listconfigs
```

Equivalent to:

```bash
docker exec openvpn ./listconfigs.sh
```

---

## SSH Access

After starting the lab, you can connect to any `ssh-ubuntu` container via SSH:

```bash
ssh root@localhost -p 2222
```

- **Username:** `root`
- **Password:** `rootpassword`

> 🔑 Ports may vary if you run multiple containers. Check the `docker-compose` mapping or logs.

---

## GUI Mode (--gui)

To start an Ubuntu server with a lightweight desktop (XFCE) and Google Chrome:

```bash
make start --gui
```

This will:

- Run an Ubuntu server with SSH + GUI (XFCE4)
- Start VNC server on `:1` (default port `5901`)
- Expose noVNC at [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)

### Access Methods

- **SSH:** `ssh root@localhost -p 2222`
- **VNC Client:** Connect to `localhost:5901`
- **Web Browser (noVNC):** [http://localhost:6080/vnc.html](http://localhost:6080/vnc.html)

### Launching Chrome

Inside the VNC session:

- Double-click **Google Chrome (Optimized)** icon on desktop, OR
- Run:

```bash
/root/start-chrome.sh
```

---

## OpenVPN Management

### Apply VPN Config to a Container

```bash
make apply-vpn-config SERVER=<container_name>
```

Steps performed:

1. Fetch `PROFILE_ID` from OpenVPN server:

```bash
docker exec openvpn ./listconfigs.sh
```

2. Copy client configuration to host and target container:

```bash
docker cp openvpn:/opt/Dockovpn_data/clients/${PROFILE_ID}/client.ovpn ./data/client.ovpn
docker cp ./data/client.ovpn <container_name>:/client.ovpn
```

3. Install OpenVPN and run client in container:

```bash
docker exec -d <container_name> bash -c "apt-get update && apt-get install -y openvpn && openvpn --config /client.ovpn --daemon"
```

> **Note:** Ensure `./data` directory exists on host.

---

### Apply Push Routes on OpenVPN Server

```bash
make apply-push-routes
```

This will:

1. Copy `push-routes.conf` from host into OpenVPN server:

```bash
docker cp ./config/push-routes.conf openvpn:/opt/Dockovpn/config/push-routes.conf
```

2. Append routes to server configuration:

```bash
docker exec -d openvpn bash -c "cat /opt/Dockovpn/config/push-routes.conf >> /opt/Dockovpn/config/server.conf"
```

---

## Verifying VPN Connection

```bash
make verify-vpn-config SERVER=<container_name>
```

This checks:

- VPN interface creation:

```bash
ip addr show tun0
```

- Routing table:

```bash
ip route show
```

Output is formatted for readability.

---

## Notes

- `DATA_DIR` is `./data` and used for storing client configuration files.
- `CONFIG_DIR` is `./config` and contains `push-routes.conf`.
- `VPN_SERVER` is default `openvpn`; adjust if container name differs.
- Ensure proper network isolation when testing VPN routes.
- Always verify network interfaces and firewall rules after configuration.

---

## TODO

- [ ] Assign a dedicated private IP for each `ssh-ubuntu` server instead of port mapping.
- [ ] Add option to load a GUI interface for Ubuntu servers (e.g., lightweight desktop environment).
- [ ] Isolate resources (CPU, memory, disk) for each Ubuntu server container to prevent interference.
- [ ] Consider automating VPN configuration application after container creation.
- [ ] Implement monitoring/logging for each Ubuntu server container.
