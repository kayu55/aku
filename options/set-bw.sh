#!/bin/bash

# Variabel
CONFIG_DIR="/etc/bandwidth"
CONFIG_FILE="${CONFIG_DIR}/bandwidth.conf"
INTERFACE="eth0" 
USAGE_FILE="/var/log/vnstat_usage.log"
YELLOW='\033[0;34m'
GREEN='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Fungsi untuk membuat direktori dan file konfigurasi
setup_config() {
  mkdir -p "$CONFIG_DIR"
  echo -n "Masukkan total kuota bandwidth (dalam TB): "
  read TOTAL_QUOTA_TB
  echo "$TOTAL_QUOTA_TB" > "$CONFIG_FILE"
}

# Memeriksa apakah direktori konfigurasi ada
if [[ ! -d $CONFIG_DIR ]]; then
  echo "Direktori konfigurasi tidak ditemukan. Mengatur direktori dan file konfigurasi..."
  setup_config
else
  # Memeriksa apakah file konfigurasi ada
  if [[ ! -f $CONFIG_FILE ]]; then
    echo "File konfigurasi tidak ditemukan. Mengatur file konfigurasi..."
    setup_config
  else
    TOTAL_QUOTA_TB=$(cat "$CONFIG_FILE")
  fi
fi

# Mengambil total penggunaan bandwidth dari vnstat
USAGE_DATA=$(vnstat --oneline | awk -F';' '{print $11}')
USAGE_GB=$(echo "$USAGE_DATA" | awk '{print $1}')

TOTAL_QUOTA_GB=$(echo "$TOTAL_QUOTA_TB * 1024" | bc)

REMAINING_GB=$(echo "$TOTAL_QUOTA_GB - $USAGE_GB" | bc)

# Menyimpan hasil ke file log
{
    echo -e "${YELLOW}--------------------------------------${NC}"
    echo -e "${CYAN}       Total Kuota Bandwidth        ${NC}"
    echo -e "${YELLOW}--------------------------------------${NC}"
    echo -e "${GREEN}Total Kuota Bandwidth: ${TOTAL_QUOTA_TB} TB${NC}"
    echo -e "${YELLOW}--------------------------------------${NC}"
    echo -e "${GREEN}        Penggunaan Saat Ini          ${NC}"
    echo -e "${YELLOW}--------------------------------------${NC}"
    echo -e "${GREEN}lPenggunaan Saat Ini: ${USAGE_GB} GB${NC}"
    echo -e "${YELLOW}--------------------------------------${NC}"
    echo -e " ${GREEN}            Sisa Bandwidth          ${NC}"
    echo -e "${YELLOW}--------------------------------------${NC}"
    echo -e "${GREEN} Sisa Bandwidth: ${REMAINING_GB} GB${NC}"
    echo -e "${YELLOW}--------------------------------------${NC}"
} > $USAGE_FILE

# Menampilkan hasil
cat $USAGE_FILE