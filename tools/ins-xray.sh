#!/bin/bash
NC='\033[0;37m'
green='\033[0;32m'

clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi

# === FIX 1: Simpen UUID + Port lawas ben gak ilang nek install ulang ===
if [ -f /etc/xray/config.json ]; then
  cp /etc/xray/config.json /tmp/config.json.bak 2>/dev/null
  UUID_LAWAS=$(grep -o '"id": "[^"]*"' /etc/xray/config.json | head -1 | cut -d'"' -f4)
  # Simpen port lawas
  VLESS_LAWAS=$(grep -A2 '"port":' /etc/xray/config.json | head -20 | grep -o '[0-9]\{5\}' | head -1)
fi

# === FIX 2: Trap - opo ae terjadi, tetep di-ON-ne maneh ===
on_exit(){
  systemctl daemon-reload 2>/dev/null
  systemctl enable xray nginx 2>/dev/null
  systemctl restart xray nginx 2>/dev/null || systemctl start xray nginx 2>/dev/null
}
trap on_exit EXIT

# Stop sekali tok neng kene, ojo neng tengah-tengah maneh
systemctl stop nginx xray 2>/dev/null || true

rm -fr /etc/nginx/conf.d/xray.conf
rm -fr /etc/systemd/system/xray.service.d

echo -e "[ ${green}INFO${NC} ] Checking... "
apt install iptables iptables-persistent -y
sleep 1
echo -e "[ ${green}INFO$NC ] Setting ntpdate"
ntpdate pool.ntp.org
timedatectl set-ntp true
timedatectl set-timezone Asia/Jakarta
systemctl enable chrony 2>/dev/null; systemctl restart chrony 2>/dev/null
echo -e "[ ${green}INFO$NC ] Setting dll"
apt clean all && apt update
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release socat cron bash-completion ntpdate chrony zip pwgen openssl netcat -y

# install xray
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
domainSock_dir="/run/xray"; [ -d $domainSock_dir ] || mkdir $domainSock_dir
chown www-data:www-data $domainSock_dir
mkdir -p /var/log/xray /etc/xray /home/vps/public_html
chown -R www-data:www-data /var/log/xray
chmod 755 /var/log/xray
touch /var/log/xray/access.log /var/log/xray/error.log /var/log/xray/access2.log /var/log/xray/error2.log

## crt xray - FIX 3: Hapus systemctl stop nginx dobel neng kene
mkdir -p /root/.acme.sh
curl -s https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# nginx renew ssl
cat > /usr/local/bin/ssl_renew.sh <<'EOSSL'
#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
EOSSL
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root 2>/dev/null; then (crontab -l 2>/dev/null; echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab; fi

chown www-data:www-data /var/log/xray /etc/xray
chmod 755 /var/log/xray
chmod 640 /var/log/xray/*.log 2>/dev/null
rm -fr /root/log-limit.txt /root/log-reboot.txt
touch /root/log-limit.txt /root/log-reboot.txt /home/limit

# install nginx
apt install -y nginx
rm -fr /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/nginx.conf"
wget -q -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/vps.conf"

# === FIX 4: Port - pake lawas nek enek, nek gak enek nembe random ===
if [ -f /tmp/config.json.bak ]; then
  # Ambil 6 port dari config lawas (urutan: vless, vmess, trojanws, vlessgrpc, vmessgrpc, trojangrpc)
  PORTS=($(grep -o '"port": [0-9]*' /tmp/config.json.bak | grep -o '[0-9]*' | grep -v 10085))
  vless=${PORTS[0]}; vmess=${PORTS[1]}; trojanws=${PORTS[2]}; vlessgrpc=${PORTS[3]}; vmessgrpc=${PORTS[4]}; trojangrpc=${PORTS[5]}
fi
[ -z "$vless" ] && vless=$((RANDOM + 10000))
[ -z "$vmess" ] && vmess=$((RANDOM + 10000))
[ -z "$trojanws" ] && trojanws=$((RANDOM + 10000))
[ -z "$vlessgrpc" ] && vlessgrpc=$((RANDOM + 10000))
[ -z "$vmessgrpc" ] && vmessgrpc=$((RANDOM + 10000))
[ -z "$trojangrpc" ] && trojangrpc=$((RANDOM + 10000))

# nginx xray.conf
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
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;
             listen 8443 ssl http2 reuseport;
             listen [::]:8443 http2 reuseport;
             listen 2096 ssl http2 reuseport;
             listen [::]:2096 http2 reuseport;
             listen 2087 ssl http2 reuseport;
             listen [::]:2087 http2 reuseport;
             listen 2053 ssl http2 reuseport;
             listen [::]:2053 http2 reuseport;
             listen 2083 ssl http2 reuseport;
             listen [::]:2083 http2 reuseport;
             server_name 127.0.0.1 localhost;
             ssl_certificate /etc/xray/xray.crt;
             ssl_certificate_key /etc/xray/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /home/vps/public_html;
        }
EOF
sed -i '$ ilocation /' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:700;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation = /vless' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:'"$vless"';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation = /vmess' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:'"$vmess"';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation = /trojan-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:'"$trojanws"';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /vless-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:'"$vlessgrpc"';' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /vmess-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:'"$vmessgrpc"';' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /trojan-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:'"$trojangrpc"';' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

# === FIX 5: UUID - pake lawas nek enek ===
if [ -n "$UUID_LAWAS" ]; then
  uuid=$UUID_LAWAS
else
  uuid=$(cat /proc/sys/kernel/random/uuid)
fi

# xray config - sama persis koyok lawas, tapi pake $uuid + $port sing wes disimpen
cat <<EOF> /etc/xray/config.json
{
  "log" : {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "dns": {
    "servers": ["https://1.1.1.1/dns-query","https://8.8.8.8/dns-query","1.1.1.1","8.8.8.8"],
    "queryStrategy": "UseIPv4"
  },
  "inbounds": [
      {"listen": "127.0.0.1","port": 10085,"protocol": "dokodemo-door","settings": {"address": "127.0.0.1"},"tag": "api"},
      {"listen": "127.0.0.1","port": "$vless","protocol": "vless","settings": {"decryption":"none","clients": [{"id": "${uuid}"
#vless
             }]},"streamSettings":{"network": "ws","wsSettings": {"path": "/vless"}}},
      {"listen": "127.0.0.1","port": "$vmess","protocol": "vmess","settings": {"clients": [{"id": "${uuid}","alterId": 0
#vmess
             }]},"streamSettings":{"network": "ws","wsSettings": {"path": "/vmess"}}},
      {"listen": "127.0.0.1","port": "$trojanws","protocol": "trojan","settings": {"decryption":"none","clients": [{"password": "${uuid}"
#trojanws
              }],"udp": true},"streamSettings":{"network": "ws","wsSettings": {"path": "/trojan-ws"}}},
      {"listen": "127.0.0.1","port": "$vlessgrpc","protocol": "vless","settings": {"decryption":"none","clients": [{"id": "${uuid}"
#vlessgrpc
             }]},"streamSettings":{"network": "grpc","grpcSettings": {"serviceName": "vless-grpc"}}},
      {"listen": "127.0.0.1","port": "$vmessgrpc","protocol": "vmess","settings": {"clients": [{"id": "${uuid}","alterId": 0
#vmessgrpc
             }]},"streamSettings":{"network": "grpc","grpcSettings": {"serviceName": "vmess-grpc"}}},
      {"listen": "127.0.0.1","port": "$trojangrpc","protocol": "trojan","settings": {"decryption":"none","clients": [{"password": "${uuid}"
#trojangrpc
               }]},"streamSettings":{"network": "grpc","grpcSettings": {"serviceName": "trojan-grpc"}}}
  ],
  "outbounds": [{"protocol": "freedom","settings": {}},{"protocol": "blackhole","settings": {},"tag": "blocked"}],
  "routing": {"rules": [
      {"type": "field","ip": ["0.0.0.0/8","10.0.0.0/8","100.64.0.0/10","169.254.0.0/16","172.16.0.0/12","192.0.0.0/24","192.0.2.0/24","192.168.0.0/16","198.18.0.0/15","198.51.100.0/24","203.0.113.0/24","::1/128","fc00::/7","fe80::/10"],"outboundTag": "blocked"},
      {"inboundTag": ["api"],"outboundTag": "api","type": "field"},
      {"type": "field","outboundTag": "blocked","protocol": ["bittorrent"]}
    ]},
  "stats": {},
  "api": {"services": ["StatsService"],"tag": "api"},
  "policy": {"levels": {"0": {"statsUserDownlink": true,"statsUserUplink": true}},"system": {"statsInboundUplink": true,"statsInboundDownlink": true,"statsOutboundUplink": true,"statsOutboundDownlink": true}}
}
EOF

# INSTALL XRAY CORE
echo -e "[ ${green}INFO${NC} ] Install Xray Core..."
XRAY_LATEST=$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
[ -z "$XRAY_LATEST" ] && XRAY_LATEST="v26.11.9"
if ! bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version "$XRAY_LATEST"; then
  echo "Xray install gagal, balekne config lawas..."
  [ -f /tmp/config.json.bak ] && cp /tmp/config.json.bak /etc/xray/config.json
  exit 1
fi
[ -x /usr/local/bin/xray ] || exit 1
/usr/local/bin/xray version || exit 1

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

systemctl daemon-reload
systemctl enable xray nginx
systemctl restart xray nginx
chown -R www-data:www-data /home/vps/public_html
echo -e "[ ${green}INFO${NC} ] Xray Install Selesai - UUID: $uuid"
systemctl is-active xray nginx