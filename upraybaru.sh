#!/bin/bash

NC='\033[0;37m'
green='\033[0;32m'
GREEN='\033[0;32m'
yell='\033[1;33m'

clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi

rm -fr /etc/nginx/conf.d/xray.conf
rm -fr /etc/nginx/conf.d/default.conf
rm -fr /etc/nginx/conf.d/grpc-tls.conf
rm -fr /etc/systemd/system/xray.service
rm -fr /etc/systemd/system/xray.service.d
rm -fr /etc/xray/config.json

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
mkdir -p /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt
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
rm -fr /root/log-limit.txt
rm -fr /root/log-reboot.txt
touch /root/log-limit.txt
touch /root/log-reboot.txt
touch /home/limit
echo "" > /root/log-limit.txt
echo "" > /root/log-reboot.txt

# ===== UPGRADE NGINX 1.18 -> 1.28 =====
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
rm -fr /etc/nginx/conf.d/default.conf
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/nginx.conf"
wget -q -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/vps.conf"

echo -e "\n${green}╔═════════════════════════════════════════════════════════════╗${NC}"
echo -e "${green}║          ⚡ A R Y A  •  X R A Y  C O R E ⚡                 ║${NC}"
echo -e "${green}║             Menggunakan rilis stabil terbaru                ║${NC}"
echo -e "${green}╚═════════════════════════════════════════════════════════════╝${NC}"
mkdir -p /usr/bin/xray /etc/xray /usr/local/etc/xray /usr/local/bin

# Random Port Xray
vless=$((RANDOM + 10000))
vmess=$((RANDOM + 10000))
trojanws=$((RANDOM + 10000))
vlessgrpc=$((RANDOM + 10000))
vmessgrpc=$((RANDOM + 10000))
trojangrpc=$((RANDOM + 10000))
xraymain=8443

# ===== NGINX HTTP : PORT 80 WS + SSH TOK - OJO GRPC NENG KENE =====
rm -fr /etc/nginx/conf.d/xray.conf
rm -fr /etc/nginx/conf.d/default.conf
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
    server_name _;
    location /vless {
        proxy_pass http://127.0.0.1:$vless;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /vmess {
        proxy_pass http://127.0.0.1:$vmess;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /trojan-ws {
        proxy_pass http://127.0.0.1:$trojanws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location /trojan {
        proxy_pass http://127.0.0.1:$trojanws;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
    location / {
        proxy_pass http://127.0.0.1:700;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOF

# ===== NGINX STREAM : 443 TOK - 2087 DIHAPUS, BEN ORA TABRAKAN KARO GRPC =====
cat >/etc/nginx/stream.conf <<EOF
stream {
    server {
        listen 443 reuseport;
        listen [::]:443 reuseport;
        listen 2096 reuseport;
        listen [::]:2096 reuseport;
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
grep -q "stream.conf" /etc/nginx/nginx.conf || echo 'include /etc/nginx/stream.conf;' >> /etc/nginx/nginx.conf

# ===== NGINX GRPC TLS 2087 - IKI KUNCINE, PAKE VARIABEL =====
cat >/etc/nginx/conf.d/grpc-tls.conf <<EOF
server {
    listen 2087 ssl;
    listen [::]:2087 ssl;
    http2 on;
    server_name _;
    ssl_certificate /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    location /vless-grpc { grpc_pass grpc://127.0.0.1:$vlessgrpc; }
    location /vmess-grpc { grpc_pass grpc://127.0.0.1:$vmessgrpc; }
    location /trojan-grpc { grpc_pass grpc://127.0.0.1:$trojangrpc; }
}
EOF

# set uuid xray
uuid=$(cat /proc/sys/kernel/random/uuid)

# xray config - Main 8443 + User edu/barat model lawas (ono # penanda)
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
          { "path": "/vless", "dest": $vless, "xver": 0 },
          { "path": "/vmess", "dest": $vmess, "xver": 0 },
          { "path": "/trojan-ws", "dest": $trojanws, "xver": 0 },
          { "path": "/vless-grpc", "dest": $vlessgrpc, "xver": 0 },
          { "path": "/vmess-grpc", "dest": $vmessgrpc, "xver": 0 },
          { "path": "/trojan-grpc", "dest": $trojangrpc, "xver": 0 },
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
               {
                 "id": "${uuid}"
#vless
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": { "path": "/vless" },
          "sockopt": { "acceptProxyProtocol": false }
        }
     },
     {
     "listen": "127.0.0.1",
     "port": "$vmess",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}", "alterId": 0
#vmess
             }
          ]
       },
       "streamSettings":{
         "network": "ws",
            "wsSettings": { "path": "/vmess" },
          "sockopt": { "acceptProxyProtocol": false }
        }
     },
     {
     "listen": "127.0.0.1",
      "port": "$trojanws",
      "protocol": "trojan",
      "settings": {
          "decryption":"none",
           "clients": [
              {
                 "password": "${uuid}"
#trojanws
              }
          ],
         "udp": true
       },
       "streamSettings":{
           "network": "ws",
           "wsSettings": { "path": "/trojan-ws" },
           "sockopt": { "acceptProxyProtocol": false }
         }
     },
    {
        "listen": "127.0.0.1",
        "port": "$vlessgrpc",
        "protocol": "vless",
        "settings": {
         "decryption":"none",
           "clients": [
             {
               "id": "${uuid}"
#vlessgrpc
             }
          ]
       },
          "streamSettings":{
             "network": "grpc",
             "grpcSettings": { "serviceName": "vless-grpc" },
           "sockopt": { "acceptProxyProtocol": false }
        }
     },
     {
      "listen": "127.0.0.1",
      "port": "$vmessgrpc",
     "protocol": "vmess",
      "settings": {
            "clients": [
               {
                 "id": "${uuid}", "alterId": 0
#vmessgrpc
             }
          ]
       },
       "streamSettings":{
         "network": "grpc",
            "grpcSettings": { "serviceName": "vmess-grpc" },
          "sockopt": { "acceptProxyProtocol": false }
        }
     },
     {
        "listen": "127.0.0.1",
        "port": "$trojangrpc",
        "protocol": "trojan",
        "settings": {
          "decryption":"none",
             "clients": [
               {
                 "password": "${uuid}"
#trojangrpc
               }
           ]
        },
         "streamSettings":{
         "network": "grpc",
           "grpcSettings": { "serviceName": "trojan-grpc" },
           "sockopt": { "acceptProxyProtocol": false }
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
echo -e "\n${green}✦ Mengunduh installer resmi Xray...${NC}"
if ! bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install; then
    echo -e "\n${NC}❌ Instalasi Xray gagal."
    exit 1
fi
if [ ! -x /usr/local/bin/xray ]; then
    echo -e "❌ Binary Xray tidak ditemukan."
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
pkill -9 nginx; sleep 2
systemctl start nginx >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
echo -e "$yell[SERVICE]$NC Restart All Service"
chown -R www-data:www-data /home/vps/public_html
echo -e "[ ${GREEN}ok${NC} ] Restart & Xray & Nginx"
systemctl daemon-reload >/dev/null 2>&1
systemctl restart xray >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1

# ===== FIX SSH WS 80 - PASTIKAN WS-STUNNEL URIP =====
systemctl enable ws-stunnel >/dev/null 2>&1
systemctl restart ws-stunnel >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
echo -e "[ ${GREEN}ok${NC} ] SSH WS Port 80 -> 700 FIXED"
curl -s -m 3 http://127.0.0.1:80/ | head -c 100; echo ""

# ===== TES PORT 80 + 2087 =====
echo -e "[ ${GREEN}ok${NC} ] TES PORT 80..."
echo "--- VLESS 80 ---"
curl -s -m 3 -v http://127.0.0.1:80/vless 2>&1 | grep -E "HTTP|Sec-Websocket"
echo "--- VMESS 80 ---"
curl -s -m 3 -v http://127.0.0.1:80/vmess 2>&1 | grep -E "HTTP|Sec-Websocket"
echo "--- TROJAN-WS 80 ---"
curl -s -m 3 -v http://127.0.0.1:80/trojan-ws 2>&1 | grep -E "HTTP|Sec-Websocket"
echo "--- SSH 80 ---"
curl -s -m 3 -v -H "Connection: Upgrade" -H "Upgrade: websocket" http://127.0.0.1:80/ 2>&1 | grep -E "HTTP"
echo "--- GRPC 2087 TLS (kudune HTTP/2 200 / 400, dudu 101) ---"
curl -sk -m 5 --http2 -v https://127.0.0.1:2087/vless-grpc/ 2>&1 | grep -E "HTTP"
curl -sk -m 5 --http2 -v https://127.0.0.1:2087/vmess-grpc/ 2>&1 | grep -E "HTTP"
curl -sk -m 5 --http2 -v https://127.0.0.1:2087/trojan-grpc/ 2>&1 | grep -E "HTTP"

# ===== FIX MENU: BEN GAK KECAMPUR NEK JSON GESER - 1x INSTALL RAMPUNG =====
cat > /root/fix-menu.sh << 'FIXEOF'
#!/bin/bash
python3 << 'PYEOF'
import pathlib, re
def auto_patch(path, proto):
    p = pathlib.Path(path)
    if not p.exists():
        print(path + " DURUNG ENEK - SKIP")
        return False
    t = p.read_text()
    orig = t
    t, n1 = re.subn(r"for idx in \[[0-9,\s]+\]:", "for idx in range(len(j['inbounds'])):", t)
    needle = "!= '" + proto + "'"
    needle2 = "!='" + proto + "'"
    lines = t.splitlines(True)
    out = []
    i = 0
    nambah = 0
    while i < len(lines):
        line = lines[i]
        out.append(line)
        if "for idx in range(len(j['inbounds'])):" in line:
            ahead = "".join(lines[i+1:i+6])
            if needle not in ahead and needle2 not in ahead:
                nxt = lines[i+1] if i+1 < len(lines) else ""
                if "try:" in nxt:
                    out.append(nxt)
                    indent = nxt[:len(nxt)-len(nxt.lstrip())] + "    "
                    out.append(indent + "if j['inbounds'][idx].get('protocol') != '" + proto + "':\n")
                    out.append(indent + "    continue\n")
                    nambah += 1
                    i += 2
                    continue
                else:
                    indent = nxt[:len(nxt)-len(nxt.lstrip())]
                    out.append(indent + "if j['inbounds'][idx].get('protocol') != '" + proto + "': continue\n")
                    nambah += 1
                    i += 1
                    continue
        if "for ib in j['inbounds']" in line or "for ib in j[" in line:
            ahead = "".join(lines[i+1:i+4])
            if needle not in ahead and needle2 not in ahead and "get('protocol')" not in ahead:
                indent = line[:len(line)-len(line.lstrip())] + "    "
                out.append(indent + "if ib.get('protocol') != '" + proto + "': continue\n")
                nambah += 1
        i += 1
    t = "".join(out)
    if t != orig:
        p.write_text(t)
        print(path + " -> patched, nambah filter: " + str(nambah))
    else:
        print(path + " -> wes bener, skip")
    return True

for f, pr in [("/usr/bin/menu-vless","vless"),("/usr/bin/menu-vmess","vmess"),("/usr/bin/menu-trojan","trojan"),("/usr/bin/add-vless","vless"),("/usr/bin/add-vmess","vmess"),("/usr/bin/add-trojan","trojan"),("/usr/bin/del-vless","vless"),("/usr/bin/del-vmess","vmess"),("/usr/bin/del-trojan","trojan")]:
    auto_patch(f, pr)
PYEOF
if [ ! -f /usr/bin/menu-vless ] || [ ! -f /usr/bin/menu-vmess ] || [ ! -f /usr/bin/menu-trojan ]; then
  if ! grep -q 'fix-menu.sh' /var/spool/cron/crontabs/root 2>/dev/null; then
    (crontab -l 2>/dev/null; echo "@reboot /bin/bash /root/fix-menu.sh >> /root/fix-menu.log 2>&1") | crontab -
    echo "Menu durung enek, fix-menu.sh dipasang neng cron @reboot"
  fi
else
  echo "Menu wes enek, fix langsung jalan"
fi
FIXEOF
chmod +x /root/fix-menu.sh
bash /root/fix-menu.sh
for m in menu-vless menu-vmess menu-trojan; do
  if [ -f /usr/bin/$m ] && ! grep -q 'fix-menu.sh' /usr/bin/$m; then
    sed -i '1a [ -f /root/fix-menu.sh ] \&\& bash /root/fix-menu.sh >/dev/null 2>\&1' /usr/bin/$m
  fi
done
echo -e "[ ${GREEN}ok${NC} ] FIX MENU rampung - VLESS/VMESS/TROJAN wes filter protocol"
# ===== END FIX MENU =====

cd /usr/bin
rm -fr upraybaru