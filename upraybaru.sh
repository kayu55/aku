#!/bin/bash

NC='\033[0;37m'
green='\033[0;32m' 

clear
clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi

rm -fr /etc/nginx/conf.d/xray.conf
rm -fr /etc/systemd/system/xray.service
rm -fr /etc/systemd/system/xray.service.d
rm -fr /etc/xray/config.json
rm -fr /etc/systemd/system/xray.service

echo -e "[ ${green}INFO${NC} ] Checking... "
apt install iptables iptables-persistent -y
sleep 1
echo -e "[ ${green}INFO$NC ] Setting ntpdate"
ntpdate pool.ntp.org 
timedatectl set-ntp true
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chronyd"
systemctl enable chronyd
systemctl restart chronyd
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chrony"
systemctl enable chrony
systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
sleep 1
echo -e "[ ${green}INFO$NC ] Setting chrony tracking"
chronyc sourcestats -v
chronyc tracking -v
echo -e "[ ${green}INFO$NC ] Setting dll"
apt clean all && apt update
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
apt install zip -y
apt install curl pwgen openssl netcat cron -y

# install xray
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir
# Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown -R www-data:www-data /var/log/xray
chmod 755 /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
## crt xray
systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

# Make Folder & Log XRay & Log Trojan
rm -fr /var/log/xray
rm -fr /home/vps/public_html
mkdir -p /var/log/xray
mkdir -p /home/vps/public_html
chown www-data.www-data /var/log/xray
chown www-data.www-data /etc/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
chown -R www-data:www-data /var/log/xray
chmod 755 /var/log/xray
chmod 640 /var/log/xray/*.log
# Make Log Autokill & Log Autoreboot
rm -fr /root/log-limit.txt
rm -fr /root/log-reboot.txt
touch /root/log-limit.txt
touch /root/log-reboot.txt
touch /home/limit
echo "" > /root/log-limit.txt
echo "" > /root/log-reboot.txt

# nginx for debian & ubuntu
install_ssl(){
    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            else
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            fi
    else
        yum install -y nginx certbot
        sleep 3s
    fi
    systemctl stop nginx.service
    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            else
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            fi
    else
        echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
        sleep 3s
    fi
}

# ===== UPGRADE NGINX 1.18 -> 1.28 (Wajib, ben STREAM stabil) =====
apt install -y curl gnupg2 ca-certificates lsb-release ubuntu-keyring
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor | tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null
echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" | tee /etc/apt/sources.list.d/nginx.list
apt update
apt install -y nginx
nginx -v

# install nginx
apt install -y nginx
cd
rm -fr /etc/nginx/sites-enabled/default
rm -fr /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/nginx.conf" 
wget -q -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/vps.conf"

#intall vray 
echo -e "\n${green}╔═════════════════════════════════════════════════════════════╗${NC}"
echo -e "${green}║          ⚡ A R Y A  •  X R A Y  C O R E ⚡                 ║${NC}"
echo -e "${green}║             Menggunakan rilis stabil terbaru                ║${NC}"
echo -e "${green}╚═════════════════════════════════════════════════════════════╝${NC}"
echo -e "${green}➜ Menyiapkan direktori Xray...${NC}"
mkdir -p /usr/bin/xray /etc/xray /usr/local/etc/xray /usr/local/bin

# Random Port Xray
vless=$((RANDOM + 10000))
vmess=$((RANDOM + 10000))
trojanws=$((RANDOM + 10000))
vlessgrpc=$((RANDOM + 10000))
vmessgrpc=$((RANDOM + 10000))
trojangrpc=$((RANDOM + 10000))
xraymain=8443

# ===== NGINX HTTP : MUNG PORT 80 / WEB, OJO 443 MANEH =====
rm -fr /etc/nginx/conf.d/xray.conf
cat >/etc/nginx/conf.d/xray.conf <<EOF
    server {
             listen 80;
             listen [::]:80;
             listen 8880;
             listen [::]:8880;
             listen 2082;
             listen [::]:2082;
             listen 8080;
             listen [::]:8080;
             listen 2052;
             listen [::]:2052;
             listen 2095;
             listen [::]:2095;
             listen 2086;
             listen [::]:2086;
             listen 700;
             listen [::]:700;
             server_name 127.0.0.1 localhost;
             root /home/vps/public_html;
        }
EOF

# ===== NGINX STREAM : IKI SING NGIRIM PROXY PROTOCOL (REAL IP) =====
cat >/etc/nginx/stream.conf <<EOF
stream {
    server {
        listen 443 reuseport;
        listen [::]:443 reuseport;
        listen 8443 reuseport;
        listen [::]:8443 reuseport;
        listen 2096 reuseport;
        listen [::]:2096 reuseport;
        listen 2087 reuseport;
        listen [::]:2087 reuseport;
        listen 2053 reuseport;
        listen [::]:2053 reuseport;
        listen 2083 reuseport;
        listen [::]:2083 reuseport;
        proxy_pass 127.0.0.1:$xraymain;
        proxy_protocol on;
        proxy_timeout 1h;
    }
}
EOF
# Daftarkan stream.conf nang nginx.conf utama, lek durung ono
grep -q "stream.conf" /etc/nginx/nginx.conf || echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf

# set uuid xray
uuid=$(cat /proc/sys/kernel/random/uuid)

# xray config - Main inbound 8443 nerimo PROXY, fallback ke inbound dalam
cat <<EOF> /etc/xray/config.json
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "dns": {
    "servers": [
      "https://1.1.1.1/dns-query",
      "https://8.8.8.8/dns-query",
      "1.1.1.1",
      "8.8.8.8"
    ],
    "queryStrategy": "UseIPv4"
  },
  "inbounds": [
      {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": $xraymain,
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          { "id": "${uuid}" }
        ],
        "fallbacks": [
          { "path": "/vless", "dest": $vless, "xver": 1 },
          { "path": "/vmess", "dest": $vmess, "xver": 1 },
          { "path": "/trojan-ws", "dest": $trojanws, "xver": 1 },
          { "path": "/vless-grpc", "dest": $vlessgrpc, "xver": 1 },
          { "path": "/vmess-grpc", "dest": $vmessgrpc, "xver": 1 },
          { "path": "/trojan-grpc", "dest": $trojangrpc, "xver": 1 },
          { "dest": 700 }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "tls",
        "tlsSettings": {
          "certificates": [
            { "certificateFile": "/etc/xray/xray.crt", "keyFile": "/etc/xray/xray.key" }
          ],
          "alpn": ["h2", "http/1.1"]
        },
        "sockopt": { "acceptProxyProtocol": true }
      }
    },
   {
     "listen": "127.0.0.1",
     "port": "$vless",
     "protocol": "vless",
      "settings": {
          "decryption":"none",
            "clients": [
               { "id": "${uuid}" },
               {"id": "db80489a-7bc3-4023-abe4-70ac8166258e","email": "edu"}
             ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": { "path": "/vless" },
          "sockopt": { "acceptProxyProtocol": true }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "$vmess",
     "protocol": "vmess",
      "settings": {
            "clients": [
               { "id": "${uuid}", "alterId": 0 }
             ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": { "path": "/vmess" },
          "sockopt": { "acceptProxyProtocol": true }
        }
     },
     {
     "listen": "127.0.0.1",
      "port": "$trojanws",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",
           "clients": [
              { "password": "${uuid}" },
              {"password": "eaba0c0b-2169-4bc2-86d6-956b1e8e8981","email": "barat"}
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": { "path": "/trojan-ws" },
           "sockopt": { "acceptProxyProtocol": true }
         }
     },
    {
        "listen": "127.0.0.1",
        "port": "$vlessgrpc",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             { "id": "${uuid}" },
             {"id": "db80489a-7bc3-4023-abe4-70ac8166258e","email": "edu"}
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": { "serviceName": "vless-grpc" },
           "sockopt": { "acceptProxyProtocol": true }
        }
     },
     {
      "listen": "127.0.0.1",
      "port": "$vmessgrpc",
     "protocol": "vmess",
      "settings": {
            "clients": [
               { "id": "${uuid}", "alterId": 0 }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": { "serviceName": "vmess-grpc" },
          "sockopt": { "acceptProxyProtocol": true }
        }
     },
     {
        "listen": "127.0.0.1",
        "port": "$trojangrpc",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               { "password": "${uuid}" },
               {"password": "eaba0c0b-2169-4bc2-86d6-956b1e8e8981","email": "barat"}
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": { "serviceName": "trojan-grpc" },
           "sockopt": { "acceptProxyProtocol": true }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": [
          "0.0.0.0/8",
          "10.0.0.0/8",
          "100.64.0.0/10",
          "169.254.0.0/16",
          "172.16.0.0/12",
          "192.0.0.0/24",
          "192.0.2.0/24",
          "192.168.0.0/16",
          "198.18.0.0/15",
          "198.51.100.0/24",
          "203.0.113.0/24",
          "::1/128",
          "fc00::/7",
          "fe80::/10"
        ],
        "outboundTag": "blocked"
      },
      { "inboundTag": [ "api" ], "outboundTag": "api", "type": "field" },
      { "type": "field", "outboundTag": "blocked", "protocol": [ "bittorrent" ] }
    ]
  },
  "stats": {},
  "api": { "services": [ "StatsService" ], "tag": "api" },
  "policy": {
    "levels": { "0": { "statsUserDownlink": true, "statsUserUplink": true } },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}
EOF
# ╔══════════════════════════════════════════════════════════════╗
# ║              📦 INSTALL X-RAY CORE STABLE TERBARU            ║
# ╚══════════════════════════════════════════════════════════════╝
echo -e "\n${green}✦ Mengunduh installer resmi Xray dan memasang versi stabil terbaru...${NC}"
if ! bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install; then
    echo -e "\n${NC}❌ Instalasi Xray gagal. Periksa koneksi internet dan log installer."
    exit 1
fi
if [ ! -x /usr/local/bin/xray ]; then
    echo -e "❌ Binary Xray tidak ditemukan di /usr/local/bin/xray. Instalasi dibatalkan.${NC}"
    exit 1
fi
/usr/local/bin/xray version || exit 1

rm -fr /etc/systemd/system/xray.service.d
rm -fr /etc/systemd/system/xray.service
cat <<EOF> /etc/systemd/system/xray.service
[Unit]
Description=Xray Service
Documentation=https://github.com/XTLS/Xray-core
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
echo -e "[ ${GREEN}ok${NC} ] Enable & Start & Restart & Xray"
systemctl daemon-reload >/dev/null 2>&1
systemctl enable xray >/dev/null 2>&1
systemctl start xray >/dev/null 2>&1
systemctl restart xray >/dev/null 2>&1
echo -e "[ ${GREEN}ok${NC} ] Enable & Start & Restart & Nginx"
systemctl daemon-reload >/dev/null 2>&1
systemctl enable nginx >/dev/null 2>&1
systemctl start nginx >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
# Restart All Service
echo -e "$yell[SERVICE]$NC Restart All Service"
chown -R www-data:www-data /home/vps/public_html
# Enable & Restart & Xray & Nginx
echo -e "[ ${GREEN}ok${NC} ] Restart & Xray & Nginx"
systemctl daemon-reload >/dev/null 2>&1
systemctl restart xray >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&

cd /usr/bin
rm -fr upraybaru