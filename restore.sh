#!/bin/bash

RED='\033[0;31m'
NC='\033[0;37m'
GREEN='\033[0;32m'
COLOR1='\033[0;37m'
clear
echo "=== RESTORE ARYA BLITAR ==="
echo "Paste Link Backup soko Email / Gmail mu"
echo "Contoh: https://drive.google.com/u/4/uc?id=xxx&export=download"
echo ""
read -rp "Link File: " -e url

if [[ -z "$url" ]]; then
  echo "Link kosong!"
  exit 1
fi

# Bersih-bersih lawas
rm -rf /root/backup /root/backup.zip /root/restore_tmp
cd /root

echo "Downloading..."
wget --no-check-certificate -O backup.zip "$url"

# CEK DOWNLOAD BENER OPO DUDU
if [ ! -s /root/backup.zip ]; then
  echo "GAGAL DOWNLOAD! Link e expired / salah"
  exit 1
fi

FILETYPE=$(file /root/backup.zip)
echo "File: $FILETYPE"
if echo "$FILETYPE" | grep -q "HTML"; then
  echo "IKI FILE HTML DUDU ZIP! Link e kudu di-klik Allow / Share Public disek neng Drive"
  echo "Buka link neng browser, nek metu 'Download anyway' berarti kudu ganti link"
  exit 1
fi

echo "Extracting..."
unzip -o backup.zip > /dev/null 2>&1

# CEK STRUKTUR - backup mu isi ne folder backup/
if [ -d "/root/backup" ]; then
  BACKUP_DIR="/root/backup"
elif [ -d "/root/restore_tmp/backup" ]; then
  BACKUP_DIR="/root/restore_tmp/backup"
else
  echo "Folder backup ora ketemu! Isi zip:"
  unzip -l backup.zip | head -n 50
  exit 1
fi

echo "Start Restore dari: $BACKUP_DIR"
systemctl stop xray nginx 2>/dev/null
sleep 1

# === 1. PASSWD & SYSTEM ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring passwd..."
cp $BACKUP_DIR/passwd /etc/ 2>/dev/null
cp $BACKUP_DIR/group /etc/ 2>/dev/null
cp $BACKUP_DIR/shadow /etc/ 2>/dev/null
cp $BACKUP_DIR/gshadow /etc/ 2>/dev/null
cp -r $BACKUP_DIR/.acme.sh /root/ 2>/dev/null
cp -r $BACKUP_DIR/scrz-prem/ /var/lib/ 2>/dev/null

# === 2. XRAY ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring Xray..."
rm -rf /etc/xray
cp -r $BACKUP_DIR/xray /etc/
# Hapus file info tok, ben config resik
rm -f /etc/xray/ports.txt /etc/xray/paths.txt

# === 3. NGINX - IKI KUNCINE AUTO KONEK ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Restoring Nginx..."
mkdir -p /etc/nginx/conf.d/
if [ -f "$BACKUP_DIR/nginx/xray.conf" ]; then
  cp $BACKUP_DIR/nginx/xray.conf /etc/nginx/conf.d/xray.conf
  echo "Nginx lawas berhasil dibalekno"
else
  echo "Nginx gak ketemu di backup!"
fi
if [ -f "$BACKUP_DIR/nginx/domain" ]; then
  cp $BACKUP_DIR/nginx/domain /etc/xray/domain
fi

# === 4. PERMISSION - OJO WWW-DATA ===
echo -e "$COLOR1│${NC}  [ ${GREEN}INFO${NC} ] • Fixing Permission..."
chown -R root:root /etc/xray
chmod 644 /etc/xray/config.json
chmod 644 /etc/nginx/conf.d/xray.conf 