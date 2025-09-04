#!/bin/bash

apt update
apt install python3 -y
apt install python3-pip -y
apt install python3-requests -y

wspro="/etc/aryapro"

mkdir -p $wspro

repo="https://raw.githubusercontent.com/kayu55/aku/main/"

wget -q -O $wspro/ws.py "${repo}wspro/ws.py"
chmod +x $wspro/ws.py


# Installing Service
cat > /etc/systemd/system/ws.service << END
[Unit]
Description=Websocket
Documentation=https://google.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python3 -O $wspro/ws.py 700
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload
systemctl enable ws.service
systemctl start ws.service
systemctl restart ws.service


rm -f $0
