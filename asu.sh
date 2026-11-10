#!/bin/bash
clear
echo "=== FIX XRAY OFF - NON MULTIPATH ==="
echo ""

# 1. MATIKNO SING TABRAKAN DISIK
echo "[1] Matikan Xray lawas sing nyangkut..."
systemctl stop xray 2>/dev/null
pkill -9 xray 2>/dev/null
sleep 2
# Cek port 10001-10004 sopo sing nganggo
echo "Cek port sing nyangkut:"
ss -tlnp | grep -E '10001|10002|10003|10004' || echo "Port 10001-10004 aman, gak ono sing nganggo"

# 2. CEK BINARY
echo ""
echo "[2] Cek binary..."
ls -lh /usr/local/bin/xray
if [ ! -f /usr/local/bin/xray ]; then
  echo "Binary ilang! Download ulang..."
  cd /tmp
  wget -q https://github.com/XTLS/Xray-core/releases/download/v1.8.11/Xray-linux-64.zip
  unzip -o Xray-linux-64.zip xray -d /usr/local/bin/ >/dev/null 2>&1
  chmod +x /usr/local/bin/xray
fi
/usr/local/bin/xray version | head -n 1

# 3. CEK CONFIG - IKI SING PALING SERING RUSAK
echo ""
echo "[3] Cek config.json..."
cat /etc/xray/config.json | python3 -m json.tool > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "KETEMU! config.json RUSAK! Tak gawekno anyar sing resik..."
  cp /etc/xray/config.json /root/config-rusak.json
  # Gawe anyar sing resik, user kosong disik, ben iso ON
  cat > /etc/xray/config.json <<'EOF'
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": 10001,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {"clients": [], "decryption": "none"},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "/vless"}},
      "tag": "vless-ws"
    },
    {
      "port": 10002,
      "listen": "127.0.0.1",
      "protocol": "vmess",
      "settings": {"clients": []},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "/vmess"}},
      "tag": "vmess-ws"
    },
    {
      "port": 10003,
      "listen": "127.0.0.1",
      "protocol": "trojan",
      "settings": {"clients": []},
      "streamSettings": {"network": "ws", "wsSettings": {"path": "/trojan"}},
      "tag": "trojan-ws"
    }
  ],
  "outbounds": [{"protocol": "freedom", "settings": {}}]
}
EOF
  echo "Config anyar wes digawe, user lawas ono neng /root/config-rusak.json - iso dibalekno manual"
else
  echo "Config OK, gak rusak"
fi

# 4. CEK LOG FOLDER & PERMISSION - IKI SING MARAI OFF NENG SCRIPT MAU
echo ""
echo "[4] Beneri permission - IKI KUNCI NE..."
mkdir -p /var/log/xray /etc/xray
touch /var/log/xray/access.log /var/log/xray/error.log
# Service ku mau nganggo User=www-data, dadi file kudu milik www-data
chown -R www-data:www-data /etc/xray /var/log/xray
chmod 644 /etc/xray/config.json
chmod 644 /etc/xray/*.crt /etc/xray/*.key 2>/dev/null
ls -l /etc/xray/config.json
ls -l /var/log/xray/

# 5. CEK SERVICE FILE - TAK GAWE SING PALING AMAN
echo ""
echo "[5] Beneri xray.service..."
cat > /etc/systemd/system/xray.service <<'EOF'
[Unit]
Description=Xray Service
After=network.target nss-lookup.target
[Service]
User=root
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
echo "Service diganti dadi User=root ben gak permission denied meneh"

# 6. CEK CERT
echo ""
echo "[6] Cek cert..."
ls -lh /etc/xray/xray.crt /etc/xray/xray.key 2>/dev/null || echo "Cert gak ono!"
if [ ! -f /etc/xray/xray.crt ]; then
  domain=$(cat /etc/xray/domain 2>/dev/null || echo "localhost")
  openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/xray/xray.key -out /etc/xray/xray.crt -subj "/CN=$domain" 2>/dev/null
  echo "Cert baru digawe"
fi

# 7. TEST MANUAL - BEN KETOK ERROR E NENG LAYAR
echo ""
echo "[7] Test Xray manual..."
/usr/local/bin/xray run -test -config /etc/xray/config.json
if [ $? -ne 0 ]; then
  echo "TEST GAGAL! Copy error neng nduwur kirim neng aku"
  exit 1
fi
echo "Test OK!"

nginx -t

# 8. RESTART
echo ""
echo "[8] Restart..."
systemctl daemon-reload
systemctl enable xray
systemctl restart xray
sleep 3
systemctl restart nginx
sleep 1

echo ""
echo "=== HASIL AKHIR ==="
systemctl is-active xray
systemctl is-active nginx
echo ""
systemctl status xray --no-pager | head -n 15
echo ""
echo "--- Log Terakhir (nek isih OFF, iki penyebab e) ---"
cat /var/log/xray/error.log | tail -n 20
echo ""
echo "Nek XRAY isih OFF, copy log neng nduwur kirim neng aku bos"