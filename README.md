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

## Check ubuntu stats

- Get server IP address
```
docker inspect ubuntu | grep IPAddress
```


- Check CPU/RAM/stats 
```
docker stats ubuntu
```

## Setup OVPN

- Get profiles
```
docker exec openvpn ./listconfigs.sh
```

- Get client.ovpn (of a profile)
```
docker cp openvpn:/opt/Dockovpn_data/clients/${PROFILE_ID}/client.ovpn ./data/client.ovpn
```

- Create new client
```
docker exec openvpn ./genclient.sh n ${PROFILE_ID}
```

- Remove client 
```
docker exec openvpn ./rmclient.sh ${PROFILE_ID}
```

- Applied `.ovpn` (external-ubuntu)
```
apt-get update
apt-get install openvpn
```

```
openvpn --config ${OPVN_FILE} --daemon
```

## Work flow

Services: 
  - openvpn (private + public network)
  - ubuntu (private network)
  - external-ubuntu (public network) (need vpn to access `ubuntu`)

  ```
    external-ubuntu --config--> OpenVPN --ssh--> ubuntu
  ```

Goal: 
  - Restrict access so that external-ubuntu can only connect to the ubuntu container via OpenVPN. Direct public access to ubuntu is blocked.
