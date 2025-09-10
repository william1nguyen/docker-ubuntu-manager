# Docker Ubuntu Manager

Fast setup for an Ubuntu server with Docker, including SSH access, persistent data, and OpenVPN configuration.

---

## Table of Contents

1. [Features](#features)
2. [Prerequisites](#prerequisites)
3. [Ubuntu Server Setup](#ubuntu-server-setup)

   - [Install Required Packages](#install-required-packages)
   - [Add User](#add-user)
   - [Start SSH Server](#start-ssh-server)

4. [Checking `private-ubuntu` Container](#checking-private-ubuntu-container)

   - [Get Server IP Address](#get-server-ip-address)
   - [Check CPU / RAM / Stats](#check-cpu--ram--stats)

5. [OpenVPN Setup](#openvpn-setup)

   - [List Profiles](#list-profiles)
   - [Get a Client Configuration](#get-a-client-configuration)
   - [Create a New Client](#create-a-new-client)
   - [Remove a Client](#remove-a-client)
   - [Apply `.ovpn` File on `external-ubuntu`](#apply-ovpn-file-on-external-ubuntu)
   - [Verify VPN Connection](#verify-vpn-connection)
   - [Add Push Routes on OpenVPN Server](#add-push-routes-on-openvpn-server)

6. [Workflow Overview](#workflow-overview)
7. [Notes](#notes)

---

## Features

- Quick setup of Ubuntu server with SSH access
- Persistent storage for data
- Integrated OpenVPN server with client management
- Private and external network configuration for lab isolation

---

## Prerequisites

Ensure your Docker environment is ready:

- Docker and Docker Compose installed
- Basic understanding of container networking

> ⚠️ **Note:** Orbstack does not support isolated networks, which is not suitable for this lab setup.
> It is recommended to use standard Docker: [Orbstack issue #1944](https://github.com/orbstack/orbstack/issues/1944)

---

## Ubuntu Server Setup

### Install Required Packages

Inside the Ubuntu container, install:

```bash
apt-get update
apt-get install -y \
    openssh-server \
    systemctl \
    sudo \
    net-tools \
    iputils-ping \
    htop
```

---

### Add User

Create a new `ubuntu` user with home directory and bash shell, and add to sudo group:

```bash
RUN useradd -m -s /bin/bash ubuntu && \
    echo 'ubuntu:mysecretpassword' | chpasswd && \
    usermod -aG sudo ubuntu
```

---

### Start SSH Server

- Managed via the container's `docker-entrypoint.sh`.

---

## Checking `private-ubuntu` Container

### Get Server IP Address

```bash
docker inspect private-ubuntu | grep IPAddress
```

### Check CPU / RAM / Stats

```bash
docker stats private-ubuntu
```

---

## OpenVPN Setup

### List Profiles

```bash
docker exec openvpn ./listconfigs.sh
```

### Get a Client Configuration

```bash
docker cp openvpn:/opt/Dockovpn_data/clients/${PROFILE_ID}/client.ovpn ./data/client.ovpn
docker cp ./data/client.ovpn external-ubuntu:/
```

### Create a New Client

```bash
docker exec openvpn ./genclient.sh n ${PROFILE_ID}
```

### Remove a Client

```bash
docker exec openvpn ./rmclient.sh ${PROFILE_ID}
```

### Apply `.ovpn` File on `external-ubuntu`

```bash
apt-get update
apt-get install -y openvpn
openvpn --config client.ovpn --daemon
```

### Verify VPN Connection

- Check interface creation:

```bash
ip addr show tun0
```

- Check routes and default gateway:

```bash
ip route show
```

### Add Push Routes on OpenVPN Server

Append existing push routes and add a custom route for `private-ubuntu`:

```bash
cat /opt/Dockovpn/config/push-routes.conf >> /opt/Dockovpn/config/server.conf
# Add custom push route
echo 'push "route 10.0.0.0 255.255.0.0"' >> /opt/Dockovpn/config/server.conf
```

> ⚠️ Adjust `10.0.0.0 255.255.0.0` to match the subnet of `private-ubuntu` container.

---

## Workflow Overview

**Services:**

- `openvpn` – connected to both private and external networks
- `private-ubuntu` – connected to private network
- `external-ubuntu` – connected to external network (needs VPN to access `ubuntu`)

**Access Flow:**

```
external-ubuntu --(VPN config)--> OpenVPN --(SSH)--> ubuntu
```

**Goal:**

- Restrict access so `external-ubuntu` can only connect to the `ubuntu` container via OpenVPN.
- Direct public access to `ubuntu` is blocked.

---

## Notes

- Ensure proper network isolation when testing VPN routes.
- Recommended Docker setup due to Orbstack network limitations.
- Always verify network interfaces and firewall rules after configuration.
