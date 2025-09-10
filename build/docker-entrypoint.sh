# !/bin/sh

service ssh start

if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
  ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ''
  ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N ''
  ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
fi

# keep container run
tail -f /dev/null