cat > /usr/bin/upray-haproxy <<'UPRAYEOF'
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
apt install -y nginx 2>/dev/null
# === FIX NGINX FINAL - SAPU KABEH LISTEN 80 DADI 81 ===
# sites-enabled
if [ -f /etc/nginx/sites-enabled/default ]; then
  sed -i 's/listen 80 default_server;/listen 81 default_server;/g' /etc/nginx/sites-enabled/default
  sed -i 's/listen \[::\]:80 default_server;/listen [::]:81 default_server;/g' /etc/nginx/sites-enabled/default
fi
# conf.d/*.conf - kabeh file, termasuk vps.conf + default.conf
sed -i 's/listen[ ]*80;/listen       81;/g' /etc/nginx/conf.d/*.conf 2>/dev/null
sed -i 's/listen 80;/listen 81;/g' /etc/nginx/conf.d/*.conf 2>/dev/null
# === FIX STREAM.CONF - OJO DIHAPUS! DIGAWE KOSONG WAE ===
# Mau rm -fr stream.conf sing marai nginx emerg failed. Saiki DILARANG HAPUS.
touch /etc/nginx/stream.conf
touch /etc/nginx/conf.d/xray.conf /etc/nginx/conf.d/grpc-tls.conf 2>/dev/null
# kosongno wae, ojo dihapus, ben include neng nginx.conf gak error
: > /etc/nginx/conf.d/xray.conf
: > /etc/nginx/conf.d/grpc-tls.conf
: > /etc/nginx/stream.conf
rm -fr /etc/systemd/system/xray.service
rm -fr /etc/systemd/system/xray.service.d
rm -fr /etc/xray/config.json
echo -e "[ ${green}INFO${NC} ] Setting waktu & install paket"
apt install -y iptables iptables-persistent chrony curl socat xz-utils wget gnupg2 dnsutils lsb-release zip pwgen openssl netcat cron bash-completion ntpdate 2>/dev/null
ntpdate pool.ntp.org
timedatectl set-ntp true
timedatectl set-timezone Asia/Jakarta
systemctl enable chrony; systemctl restart chrony
echo -e "[ ${green}INFO${NC} ] Downloading Xray core"
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir $domainSock_dir
chown www-data.www-data $domainSock_dir
mkdir -p /var/log/xray /etc/xray /home/vps/public_html
chown -R www-data:www-data /var/log/xray /etc/xray
touch /var/log/xray/access.log /var/log/xray/error.log
mkdir -p /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key; chmod 644 /etc/xray/xray.crt
echo -n '#!/bin/bash
/etc/init.d/haproxy stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key; chmod 644 /etc/xray/xray.crt
cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/haproxy/xray.pem
chown haproxy:haproxy /etc/haproxy/xray.pem
chmod 640 /etc/haproxy/xray.pem
/etc/init.d/haproxy start
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "0 0 */5 * * /usr/local/bin/ssl_renew.sh") | crontab;fi
echo -e "${green}╔══════════════════════════════════════════════════╗${NC}"
echo -e "${green}║   ⚡ ARYA • XRAY HAPROXY WS + GRPC - VERSI ENTENG ⚡  ║${NC}"
echo -e "${green}╚══════════════════════════════════════════════════╝${NC}"
mkdir -p /usr/bin/xray /etc/xray /usr/local/etc/xray
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
mkdir -p /var/lib/haproxy /etc/haproxy/errors /run/haproxy
chown haproxy:haproxy /var/lib/haproxy /run/haproxy
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
    bind *:2087 ssl crt /etc/haproxy/xray.pem alpn h2,http/1.1
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
cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/haproxy/xray.pem
chown haproxy:haproxy /etc/haproxy/xray.pem
chmod 640 /etc/haproxy/xray.pem
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
          {
            "id": "${uuid}"
          }
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
            {
              "certificateFile": "/etc/xray/xray.crt",
              "keyFile": "/etc/xray/xray.key"
            }
          ],
          "alpn": ["h2", "http/1.1"]
        },
        "sockopt": {
          "acceptProxyProtocol": true
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "$vless",
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "${uuid}"
#vless
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vless"
        },
        "sockopt": {
          "acceptProxyProtocol": false
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "$vmess",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#vmess
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/vmess"
        },
        "sockopt": {
          "acceptProxyProtocol": false
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "$trojanws",
      "protocol": "trojan",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "password": "${uuid}"
#trojanws
          }
        ],
        "udp": true
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
          "path": "/trojan-ws"
        },
        "sockopt": {
          "acceptProxyProtocol": false
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "$vlessgrpc",
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "${uuid}"
#vlessgrpc
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vless-grpc"
        },
        "sockopt": {
          "acceptProxyProtocol": false
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "$vmessgrpc",
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "${uuid}",
            "alterId": 0
#vmessgrpc
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "vmess-grpc"
        },
        "sockopt": {
          "acceptProxyProtocol": false
        }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "$trojangrpc",
      "protocol": "trojan",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "password": "${uuid}"
#trojangrpc
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": {
          "serviceName": "trojan-grpc"
        },
        "sockopt": {
          "acceptProxyProtocol": false
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    },
    {
      "protocol": "blackhole",
      "settings": {},
      "tag": "blocked"
    }
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
      {
        "inboundTag": [ "api" ],
        "outboundTag": "api",
        "type": "field"
      },
      {
        "type": "field",
        "outboundTag": "blocked",
        "protocol": [ "bittorrent" ]
      }
    ]
  },
  "stats": {},
  "api": {
    "services": [ "StatsService" ],
    "tag": "api"
  },
  "policy": {
    "levels": {
      "0": {
        "statsUserDownlink": true,
        "statsUserUplink": true
      }
    },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink" : true,
      "statsOutboundDownlink" : true
    }
  }
}
EOF
if ! bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install; then echo "❌ Instalasi Xray gagal."; exit 1; fi
mkdir -p /var/log/xray /etc/xray
touch /var/log/xray/access.log /var/log/xray/error.log
chown -R www-data:www-data /var/log/xray /etc/xray
chmod 755 /var/log/xray; chmod 644 /var/log/xray/*.log
chown www-data:www-data /etc/xray/xray.crt /etc/xray/xray.key
chmod 640 /etc/xray/xray.key; chmod 644 /etc/xray/xray.crt
cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/haproxy/xray.pem
chown haproxy:haproxy /etc/haproxy/xray.pem
chmod 640 /etc/haproxy/xray.pem
# PASTIKNO STREAM.CONF ONO MANEH SAK DURUNGE RESTART, BEN GAK EMERG
touch /etc/nginx/stream.conf
touch /etc/nginx/conf.d/xray.conf /etc/nginx/conf.d/grpc-tls.conf 2>/dev/null
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
systemctl enable xray haproxy nginx ws-stunnel 2>/dev/null
systemctl restart nginx
sleep 1
systemctl restart xray haproxy ws-stunnel 2>/dev/null
sleep 2
echo -e "[ ${GREEN}ok${NC} ] STATUS: XRAY=$(systemctl is-active xray) HAPROXY=$(systemctl is-active haproxy) NGINX=$(systemctl is-active nginx)"
nginx -t
curl -s -o /dev/null -w "vless port 80: %{http_code} (400 = bener)\n" -m 3 http://127.0.0.1:80/vless
cat /etc/xray/port.conf
UPRAYEOF
chmod +x /usr/bin/upray-haproxy
crontab -l 2>/dev/null | grep -v 'fix-menu.sh' | crontab -
rm -f /root/fix-menu.sh /root/cek-haproxy.sh /root/cek-bener.sh
echo "WES - VERSI PALING FINAL, stream.conf GAK DIHAPUS MANEH"

upray-haproxy