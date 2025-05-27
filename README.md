# docker-ubuntu-manager

fast setup ubuntu server with docker script

## Setup an ubuntu server with ssh access and persistent data

- Install required packages

  - openssh-server: SSH server
  - systemctl: systemd control
  - sudo
  - net-tools: for ifconfig, netstat, route ... commands
  - iputils-ping: for ping command (test network)
  - htop: monitor UI (CPU / RAM)

- Add new user `ubuntu` (`-m` for createing /home, `-s` for specific shell)
- Add `ubuntu` to Group `sudo`

  ```
  RUN useradd -m -s /bin/bash ubuntu && \
  echo 'ubuntu:mysecretpassword' | chpasswd && \
  usermod -aG sudo ubuntu
  ```

- Start ssh server (docker-entrypoint.sh)
