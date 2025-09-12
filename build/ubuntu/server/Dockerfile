FROM ubuntu:22.04

RUN apt-get update
RUN apt-get install -y \
  openssh-server \
  curl \
  vim \
  wget \
  htop \
  net-tools \ 
  iputils-ping \
  iptables \ 
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Setup VPN option
RUN apt-get update
RUN apt-get install -y openvpn

RUN mkdir /var/run/sshd

RUN useradd -m -s /bin/bash ubuntu && \
  echo 'ubuntu:mysecretpassword' | chpasswd && \
  usermod -aG sudo ubuntu

RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config && \
  echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config && \
  echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config

RUN echo 'root:rootpassword' | chpasswd

EXPOSE 22

COPY docker-entrypoint.sh ./docker-entrypoint.sh
RUN chmod +x docker-entrypoint.sh

ENTRYPOINT ["sh", "docker-entrypoint.sh"]