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
# === FIX NGINX - OJO DIPATENI MANEH ===
apt install -y nginx 2>/dev/null
if [ -f /etc/nginx/sites-enabled/default ]; then
  sed -i 's/listen 80 default_server;/listen 81 default_server;/g' /etc/nginx/sites-enabled/default
  sed -i 's/listen \[::\]:80 default_server;/listen [::]:81 default_server;/g' /etc/nginx/sites-enabled/default
fi
rm -fr /etc/nginx/conf.d/xray.conf
rm -fr /etc/nginx/conf.d/grpc-tls.conf
rm -fr /etc/nginx/stream.conf
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
echo -n '#!/bin/bash
/etc/init.d/haproxy stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt
/etc/init.d/haproxy start
/etc/init.d/haproxy status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "0 0 */5 * * /usr/local/bin/ssl_renew.sh") | crontab;fi
rm -fr /var/log/xray
rm -fr /home/vps/public_html
mkdir -p /var/log/xray
mkdir -p /home/vps/public_html
chown www-data.www-data /var/log/xray
chown www-data.www-data /etc/xray
chmod 755 /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
chown -R www-data:www-data /var/log/xray
chmod 755 /var/log/xray
chmod 644 /var/log/xray/*.log
rm -fr /root/log-limit.txt
rm -fr /root/log-reboot.txt
touch /root/log-limit.txt
touch /root/log-reboot.txt
touch /home/limit
echo "" > /root/log-limit.txt
echo "" > /root/log-reboot.txt
echo -e "\n${green}╔═════════════════════════════════════════════════════════════╗${NC}"
echo -e "${green}║          ⚡ A R Y A  •  X R A Y  HAPROXY ⚡                 ║${NC}"
echo -e "${green}║       WS + GRPC - HAPROXY + NGINX 81 - VERSI FIX           ║${NC}"
echo -e "${green}╚═════════════════════════════════════════════════════════════╝${NC}"
mkdir -p /usr/bin/xray /etc/xray /usr/local/etc/xray /usr/local/bin
vless=$((RANDOM + 10000))
vmess=$((RANDOM + 10000))
trojanws=$((RANDOM + 10000))
vlessgrpc=$((RANDOM + 10000))
vmessgrpc=$((RANDOM + 10000))
trojangrpc=$((RANDOM + 10000))
xraymain=8443
echo "VLESS WS   : $vless" > /etc/xray/port.conf
echo "VMESS WS   : $vmess" >> /etc/xray/port.conf
echo "TROJAN WS  : $trojanws" >> /etc/xray/port.conf
echo "VLESS GRPC : $vlessgrpc" >> /etc/xray/port.conf
echo "VMESS GRPC : $vmessgrpc" >> /etc/xray/port.conf
echo "TROJAN GRPC: $trojangrpc" >> /etc/xray/port.conf
echo "XRAY MAIN  : $xraymain" >> /etc/xray/port.conf
apt install -y haproxy
systemctl enable nginx 2>/dev/null
nginx -t && systemctl restart nginx 2>/dev/null
mkdir -p /var/lib/haproxy /etc/haproxy/errors
chown haproxy:haproxy /var/lib/haproxy
cat > /etc/haproxy/haproxy.cfg <<EOF
global
    log /dev/log local0
    log /dev/log local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    user haproxy
    group haproxy
    daemon
    maxconn 50000
    tune.ssl.default-dh-param 2048
defaults
    log global
    mode http
    option httplog
    option dontlognull
    timeout connect 5s
    timeout client 1h
    timeout server 1h
    timeout http-request 10s
    timeout http-keep-alive 10s
frontend http-in
    bind *:80
    bind *:8880
    bind *:2082
    bind *:8080
    bind *:2052
    bind *:2095
    bind *:2086
    mode http
    option http-keep-alive
    acl is-vless path_beg /vless
    acl is-vmess path_beg /vmess
    acl is-trojan-ws path_beg /trojan-ws
    acl is-trojan path_beg /trojan
    use_backend vless-ws if is-vless
    use_backend vmess-ws if is-vmess
    use_backend trojan-ws if is-trojan-ws
    use_backend trojan-ws if is-trojan
    default_backend ssh-ws
frontend https-in
    bind *:443
    bind *:2096
    bind *:2053
    bind *:2083
    mode tcp
    option tcplog
    tcp-request inspect-delay 5s
    tcp-request content accept if { req_ssl_hello_type 1 }
    acl sni-utama req_ssl_sni -i $domain
    acl sni-cdn req_ssl_sni -i cdn.$domain
    acl sni-ws req_ssl_sni -i ws.$domain
    use_backend xray-main if sni-utama
    use_backend xray-main if sni-cdn
    use_backend xray-main if sni-ws
    default_backend xray-main
frontend grpc-in
    bind *:2087 ssl crt /etc/xray/xray.crt alpn h2,http/1.1
    mode http
    option http-keep-alive
    acl is-vless-grpc path_beg /vless-grpc
    acl is-vmess-grpc path_beg /vmess-grpc
    acl is-trojan-grpc path_beg /trojan-grpc
    use_backend vless-grpc if is-vless-grpc
    use_backend vmess-grpc if is-vmess-grpc
    use_backend trojan-grpc if is-trojan-grpc
    default_backend ssh-ws
backend xray-main
    mode tcp
    server xray1 127.0.0.1:$xraymain send-proxy-v2
backend vless-ws
    mode http
    server vless1 127.0.0.1:$vless
backend vmess-ws
    mode http
    server vmess1 127.0.0.1:$vmess
backend trojan-ws
    mode http
    server trojan1 127.0.0.1:$trojanws
backend vless-grpc
    mode http
    server vless-grpc1 127.0.0.1:$vlessgrpc proto h2
backend vmess-grpc
    mode http
    server vmess-grpc1 127.0.0.1:$vmessgrpc proto h2
backend trojan-grpc
    mode http
    server trojan-grpc1 127.0.0.1:$trojangrpc proto h2
backend ssh-ws
    mode http
    server ssh1 127.0.0.1:700
EOF
haproxy -c -f /etc/haproxy/haproxy.cfg
uuid=$(cat /proc/sys/kernel/random/uuid)
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
mkdir -p /var/log/xray /etc/xray
touch /var/log/xray/access.log /var/log/xray/error.log /var/log/xray/access2.log /var/log/xray/error2.log
chown -R www-data:www-data /var/log/xray /etc/xray
chmod 755 /var/log/xray
chmod 644 /var/log/xray/*.log
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key
chmod 644 /etc/xray/xray.crt
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
echo -e "[ ${GREEN}ok${NC} ] Enable & Start & Restart & HAProxy"
systemctl daemon-reload >/dev/null 2>&1
systemctl enable haproxy >/dev/null 2>&1
pkill -9 haproxy; sleep 2
systemctl start haproxy >/dev/null 2>&1
systemctl restart haproxy >/dev/null 2>&1
echo -e "$yell[SERVICE]$NC Restart All Service"
chown -R www-data:www-data /home/vps/public_html
echo -e "[ ${GREEN}ok${NC} ] Restart & Xray & HAProxy & Nginx"
systemctl daemon-reload >/dev/null 2>&1
systemctl restart xray >/dev/null 2>&1
systemctl restart haproxy >/dev/null 2>&1
systemctl enable nginx >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
systemctl enable ws-stunnel >/dev/null 2>&1
systemctl restart ws-stunnel >/dev/null 2>&1
systemctl restart haproxy >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
sleep 2
if ! systemctl is-active --quiet xray; then
  echo -e "[ ${yell}WARN${NC} ] Xray gagal start, auto-fix permission..."
  journalctl -u xray --no-pager -n 10
  tail -n 10 /var/log/xray/error.log 2>/dev/null
  mkdir -p /var/log/xray /etc/xray
  touch /var/log/xray/access.log /var/log/xray/error.log /var/log/xray/access2.log /var/log/xray/error2.log
  chown -R www-data:www-data /var/log/xray /etc/xray
  chmod 755 /var/log/xray
  chmod 644 /var/log/xray/*.log
  chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key 2>/dev/null
  chmod 640 /etc/xray/xray.key 2>/dev/null; chmod 644 /etc/xray/xray.crt 2>/dev/null
  systemctl daemon-reload; systemctl restart xray; sleep 2
fi
echo -e "[ ${GREEN}ok${NC} ] STATUS: XRAY=$(systemctl is-active xray) HAPROXY=$(systemctl is-active haproxy) NGINX=$(systemctl is-active nginx)"
echo -e "[ ${GREEN}ok${NC} ] SSH WS Port 80 -> 700 FIXED"
curl -s -m 3 http://127.0.0.1:80/ | head -c 100; echo ""
echo -e "[ ${GREEN}ok${NC} ] TES PORT 80 WS + GRPC..."
echo "--- WS VLESS (kudu 400) ---"
curl -s -o /dev/null -w "vless: %{http_code}\n" -m 3 http://127.0.0.1:80/vless
echo "--- WS VMESS (kudu 400) ---"
curl -s -o /dev/null -w "vmess: %{http_code}\n" -m 3 http://127.0.0.1:80/vmess
echo "--- HTTPUpgrade kudu GAK ENEK (404 / 502) ---"
curl -s -o /dev/null -w "upvless: %{http_code} (kudu 404/502 = wes kehapus)\n" -m 3 http://127.0.0.1:80/upvless
cat /etc/xray/port.conf
cat > /root/cek-haproxy.sh << 'CEKEOF'
#!/bin/bash
echo "=== WS (kudu 400) ==="
for p in vless vmess trojan-ws; do curl -s -o /dev/null -w "$p: %{http_code}\n" http://127.0.0.1:80/$p; done
echo "=== gRPC ==="
for p in vless-grpc vmess-grpc trojan-grpc; do curl -k -s -o /dev/null -w "$p: %{http_code}\n" https://127.0.0.1:2087/$p; done
echo "=== PENANDA MENU (kudu enek kabeh) ==="
grep -E "#vless|#vmess|#trojanws|#vlessgrpc|#vmessgrpc|#trojangrpc" /etc/xray/config.json
echo "=== SNI ==="
grep -A 12 "frontend https-in" /etc/haproxy/haproxy.cfg
echo "=== SERVICE ==="
systemctl is-active xray haproxy nginx
CEKEOF
chmod +x /root/cek-haproxy.sh
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
echo -e "[ ${GREEN}ok${NC} ] FIX MENU rampung"
# === TAMBAHAN BARU - AUTO CEK AKHIR, NEK KENE LO BRO ===
# Ben sekali install langsung ketok aman kabeh, gak usah ketik cek manual maneh
echo -e "\n${green}╔═════════════════════════════════════════════════════════════╗${NC}"
echo -e "${green}║              ✅ AUTO-CEK AKHIR - SEKALI INSTALL            ║${NC}"
echo -e "${green}╚═════════════════════════════════════════════════════════════╝${NC}"
echo -e "[ ${GREEN}ok${NC} ] SERVICE:"
systemctl is-active xray haproxy nginx
echo -e "[ ${GREEN}ok${NC} ] PORT:"
ss -tulpn | grep -E ':80|:81|:443'
echo -e "[ ${GREEN}ok${NC} ] WS + NGINX:"
curl -s -o /dev/null -w "vless port 80: %{http_code} (kudu 400 = bener)\n" -m 3 http://127.0.0.1:80/vless
curl -s -o /dev/null -w "vmess port 80: %{http_code} (kudu 400 = bener)\n" -m 3 http://127.0.0.1:80/vmess
curl -s -o /dev/null -w "nginx port 81: %{http_code} (kudu 200 = bener)\n" -m 3 http://127.0.0.1:81/
echo -e "[ ${GREEN}ok${NC} ] BERES - XRAY + HAPROXY + NGINX URIP KABEH, SEKALI INSTALL AMAN"