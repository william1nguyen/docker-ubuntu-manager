FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV TERM=xterm

RUN apt-get update && apt-get install -y \
    openssh-server \
    curl vim wget htop net-tools iputils-ping iptables \
    openvpn \
    xfce4 xfce4-terminal tightvncserver novnc websockify \
    dbus-x11 \
    && wget -qO- https://dl.google.com/linux/linux_signing_key.pub \
    | gpg --dearmor -o /usr/share/keyrings/google-linux.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-linux.gpg] https://dl.google.com/linux/chrome/deb/ stable main" \
    > /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update && apt-get install -y google-chrome-stable \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

RUN echo 'root:rootpassword' | chpasswd

RUN mkdir -p /root/.vnc && \
    echo "rootpassword" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

COPY xstartup /root/.vnc/xstartup
COPY start-chrome.sh /root/start-chrome.sh
COPY Chrome.desktop /root/Desktop/Chrome.desktop
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod +x /root/.vnc/xstartup && \
    chmod +x /root/start-chrome.sh && \
    chmod +x /root/Desktop/Chrome.desktop && \
    chmod +x /docker-entrypoint.sh && \
    mkdir -p /root/Desktop

EXPOSE 22 5901 6080

ENTRYPOINT ["/docker-entrypoint.sh"]