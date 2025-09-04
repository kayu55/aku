#!/bin/bash

if [ "${EUID}" -ne 0 ]; then
echo -e "${EROR} Please Run This Script As Root User !"
exit 1
fi
clear
export LANG='en_US.UTF-8'
export LANGUAGE='en_US.UTF-8'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'
BIRed='\033[1;91m'
red='\e[1;31m'
bo='\e[1m'
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
tyblue='\e[1;36m'
purple() { echo -e "\\033[35;1m${*}\\033[0m"; }
tyblue() { echo -e "\\033[36;1m${*}\\033[0m"; }
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
export EROR="[${RED} ERROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"
export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"
clear
clear
if [ "${EUID}" -ne 0 ]; then
echo "You need to run this script as root"
exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
echo "OpenVZ is not supported"
exit 1
fi
localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi
mkdir -p /etc/xray
echo -e "${green} Welcome To AutoScript......${NC} "
sleep 2
echo -e "[ ${green}INFO${NC} ] Preparing the install file"
apt install git curl -y >/dev/null 2>&1
echo -e "[ ${green}INFO${NC} ] installation file is ready"

sleep 3
if [[ -r /etc/xray/domain ]]; then
clear
echo -e "${INFO} Having Script Detected !"
echo -e "${INFO} If You Replacing Script, All Client Data On This VPS Will Be Cleanup !"
read -p "Are You Sure Wanna Replace Script ? (Y/N) " josdong
if [[ $josdong == "Y" ]]; then
clear
echo -e "${INFO} Starting Replacing Script !"
elif [[ $josdong == "y" ]]; then
clear
echo -e "${INFO} Starting Replacing Script !"
rm -rf /var/lib/scrz-prem
elif [[ $josdong == "N" ]]; then
echo -e "${INFO} Action Canceled !"
exit 1
elif [[ $josdong == "n" ]]; then
echo -e "${INFO} Action Canceled !"
exit 1
else
echo -e "${EROR} Your Input Is Wrong !"
exit 1
fi
clear
fi
echo -e "${GREEN}Starting Installation............${NC}"
# --- Disable AppArmor (Ubuntu 24.04) ---
systemctl disable --now apparmor >/dev/null 2>&1
systemctl stop apparmor >/dev/null 2>&1
update-rc.d -f apparmor remove >/dev/null 2>&1 # Ini mungkin tidak ada di semua sistem, tapi aman.
apt-get purge apparmor apparmor-utils -y >/dev/null 2>&1

clear
# --- Instalasi Tools Awal ---
echo -e "${GREEN}Instalasi Tools Awal...${NC}"
#wget https://raw.githubusercontent.com/kipas77pro/aku/refs/heads/main/tools2.sh -O tools2.sh
#chmod +x tools2.sh
#bash tools2.sh
start=$(date +%s)
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# --- Update dan Instal Dependensi Umum untuk Ubuntu 24.04 ---
echo -e "${GREEN}Memperbarui sistem dan menginstal dependensi...${NC}"
apt update -y && apt upgrade -y
apt install git curl python3 apt  figlet python3-pip apt-transport-https ca-certificates software-properties-common ntpdate wget netcat-openbsd ncurses-bin chrony jq -y
wget https://github.com/fullstorydev/grpcurl/releases/download/v1.9.1/grpcurl_1.9.1_linux_x86_64.tar.gz -O /tmp/grpcurl.tar.gz && tar -xzf /tmp/grpcurl.tar.gz -C /tmp/ && sudo mv /tmp/grpcurl /usr/local/bin/ && sudo chmod +x /usr/local/bin/grpcurl
wget https://raw.githubusercontent.com/XTLS/Xray-core/main/app/stats/command/command.proto -O stats.proto
# buat ubuntu 22 dan 25 
apt install netcat-traditional -y
apt install netcat-openbsd -y
apt install nodejs -y
apt install npm && npm install -g pm2

clear
clear && clear && clear
clear;clear;clear
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo -e "Anda Ingin Menggunakan Domain Pribadi ?"
echo -e "Atau Ingin Menggunakan Domain Otomatis ?"
echo -e "Jika Ingin Menggunakan Domain Pribadi, Ketik ${GREEN}1${NC}"
echo -e "dan Jika Ingin menggunakan Domain Otomatis, Ketik ${GREEN}2${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo ""
read -p "$( echo -e "${GREEN}Input Your Choose ? ${NC}(${YELLOW}1/2${NC})${NC} " )" choose_domain
if [[ $choose_domain == "2" ]]; then # // Using Automatic Domain
sleep 2
elif [[ $choose_domain == "1" ]]; then
clear
clear && clear && clear
clear;clear;clear
echo -e "${GREEN}Indonesian Language${NC}"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo -e "Silakan Pointing Domain Anda Ke IP VPS"
echo -e "Untuk Caranya Arahkan NS Domain Ke Cloudflare"
echo -e "Kemudian Tambahkan A Record Dengan IP VPS"
echo -e "${YELLOW}-----------------------------------------------------${NC}"
echo ""
echo ""
read -p "Input Your Domain : " domain
if [[ $domain == "" ]]; then
clear
echo -e "${EROR} No Input Detected !"
exit 1
fi
mkdir -p /usr/bin
rm -fr /usr/local/bin/xray
rm -fr /etc/nginx
rm -fr /usr/local/bin/stunnel
rm -fr /usr/local/bin/stunnel4
rm -fr /var/lib/scrz-prem/
rm -fr /usr/bin/xray
rm -fr /etc/xray
rm -fr /usr/local/etc/xray
mkdir -p /etc/nginx
mkdir -p /var/lib/scrz-prem/
mkdir -p /usr/bin/xray
mkdir -p /etc/xray
mkdir -p /usr/local/etc/xray
echo "$domain" > /etc/${Auther}/domain.txt
echo "IP=$domain" > /var/lib/scrz-prem/ipvps.conf
echo "$domain" > /root/domain
domain=$(cat /root/domain)
cp -r /root/domain /etc/xray/domain
clear
else
echo -e "${EROR} Please Choose 1 & 2 Only !"
exit 1
fi
echo -e "┌─────────────────────────────────────────┐"
echo -e " \E[42;1;37m          >>> Install Tools <<<        \E[0m$NC"
echo -e "└─────────────────────────────────────────┘"
sleep 1
wget -q https://raw.githubusercontent.com/kayu55/aku/main/tools2.sh && chmod +x tools2.sh && ./tools2.sh
echo -e "┌─────────────────────────────────────────┐"
echo -e " \E[42;1;37m          >>> Install SSH / WS <<<        \E[0m$NC"
echo -e "└─────────────────────────────────────────┘"
sleep 1
wget -q https://raw.githubusercontent.com/kayu55/aku/main/ssh/ssh-vpn4.sh && chmod +x ssh-vpn4.sh && ./ssh-vpn4.sh
wget -q https://raw.githubusercontent.com/kayu55/aku/main/wspro/wspro.sh && chmod +x wspro.sh && ./wspro.sh
echo -e "┌─────────────────────────────────────────┐"
echo -e " \E[42;1;37m            >>> Install Xray <<<         \E[0m$NC"
echo -e "└─────────────────────────────────────────┘"
sleep 1
wget -q https://raw.githubusercontent.com/kayu55/aku/main/tools/ins-xray.sh && chmod +x ins-xray.sh && ./ins-xray.sh
sleep 1
echo -e "┌─────────────────────────────────────────┐"
echo -e " \E[42;1;37m           >>> Install Backup <<<           \E[0m$NC"
echo -e "└─────────────────────────────────────────┘"
sleep 1
wget -q https://raw.githubusercontent.com/kayu55/aku/main/backup/set-br.sh && chmod +x set-br.sh && ./set-br.sh
sleep 1

echo -e "${GREEN}Download Data Menu${NC}"
wget -q -O /usr/bin/usernew "https://raw.githubusercontent.com/kayu55/aku/main/usernew.sh"
wget -q -O /usr/bin/trialssh "https://raw.githubusercontent.com/kayu55/aku/main/trialssh.sh"
wget -q -O /usr/bin/add-ws "https://raw.githubusercontent.com/kayu55/aku/main/add-ws.sh"
wget -q -O /usr/bin/trialvmess "https://raw.githubusercontent.com/kayu55/aku/main/trialvmess.sh"
wget -q -O /usr/bin/add-vless "https://raw.githubusercontent.com/kayu55/aku/main/add-vless.sh"
wget -q -O /usr/bin/trialvless "https://raw.githubusercontent.com/kayu55/aku/main/trialvless.sh"
wget -q -O /usr/bin/add-tr "https://raw.githubusercontent.com/kayu55/aku/main/add-tr.sh"
wget -q -O /usr/bin/trialtrojan "https://raw.githubusercontent.com/kayu55/aku/main/trialtrojan.sh"
wget -q -O /usr/bin/autoreboot "https://raw.githubusercontent.com/kayu55/aku/main/options/autoreboot.sh"
wget -q -O /usr/bin/restart "https://raw.githubusercontent.com/kayu55/aku/main/websocket_engine/restart.sh"
wget -q -O /usr/bin/tendang "https://raw.githubusercontent.com/kayu55/aku/main/options/tendang.sh"
wget -q -O /usr/bin/clearlog "https://raw.githubusercontent.com/kayu55/aku/main/options/clearlog.sh"
wget -q -O /usr/bin/running "https://raw.githubusercontent.com/kayu55/aku/main/websocket_engine/running.sh"
wget -q -O /usr/bin/speedtest "https://raw.githubusercontent.com/kayu55/aku/main/tools/speedtest_cli.py"
wget -q -O /usr/bin/cek-bandwidth "https://raw.githubusercontent.com/kayu55/aku/main/options/cek-bandwidth.sh"
wget -q -O /usr/bin/menu-vless "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-vless.sh"
wget -q -O /usr/bin/menu-vmess "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-vmess.sh"
wget -q -O /usr/bin/menu-trojan "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-trojan.sh"
wget -q -O /usr/bin/menu-ssh "https://raw.githubusercontent.com/kayu55/aku/main/tools/menu-ssh.sh"
wget -q -O /usr/bin/menu-backup "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-backup.sh"
wget -q -O /usr/bin/menu "https://raw.githubusercontent.com/kayu55/aku/main/m2/menu.sh"
wget -q -O /usr/bin/xp "https://raw.githubusercontent.com/kayu55/aku/main/xp.sh"
wget -q -O /usr/bin/addhost "https://raw.githubusercontent.com/kayu55/aku/main/m2/addhost.sh"
wget -q -O /usr/bin/certxray "https://raw.githubusercontent.com/kayu55/aku/main/menu/cf.sh"
wget -q -O /usr/bin/menu-set "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-set.sh"
wget -q -O /usr/bin/info "https://raw.githubusercontent.com/kayu55/aku/main/options/info.sh"
wget -q -O /usr/bin/jam "https://raw.githubusercontent.com/kayu55/aku/main/tools/jam.sh"
wget -q -O /usr/bin/babi "https://raw.githubusercontent.com/kayu55/aku/main/babi.sh"
wget -q -O /usr/bin/update-xray "https://raw.githubusercontent.com/kayu55/aku/main/tools/update-xray.sh"
wget -q -O /usr/bin/set-bw "https://raw.githubusercontent.com/kayu55/aku/main/options/set-bw.sh"
wget -q -O /usr/bin/px "https://raw.githubusercontent.com/kayu55/aku/main/websocket_engine/px.sh"
wget -q -O /usr/bin/cekssh "https://raw.githubusercontent.com/kayu55/aku/main/cekssh.sh"
wget -q -O /usr/bin/cekudp "https://raw.githubusercontent.com/kayu55/aku/main/cekudp.sh"

chmod +x /usr/bin/jam
chmod +x /usr/bin/update-xray
chmod +x /usr/bin/babi
chmod +x /usr/bin/usernew
chmod +x /usr/bin/trialssh
chmod +x /usr/bin/add-ws
chmod +x /usr/bin/trialvmess
chmod +x /usr/bin/add-vless
chmod +x /usr/bin/trialvless
chmod +x /usr/bin/add-tr
chmod +x /usr/bin/trialtrojan
chmod +x /usr/bin/autoreboot
chmod +x /usr/bin/restart
chmod +x /usr/bin/tendang
chmod +x /usr/bin/clearlog
chmod +x /usr/bin/running
chmod +x /usr/bin/speedtest
chmod +x /usr/bin/cek-bandwidth
chmod +x /usr/bin/menu-vless
chmod +x /usr/bin/menu-vmess
chmod +x /usr/bin/menu-trojan
chmod +x /usr/bin/menu-ssh
chmod +x /usr/bin/menu-backup
chmod +x /usr/bin/menu
chmod +x /usr/bin/xp
chmod +x /usr/bin/addhost
chmod +x /usr/bin/certxray
chmod +x /usr/bin/menu-set
chmod +x /usr/bin/info
chmod +x /usr/bin/set-bw
chmod +x /usr/bin/px
chmod +x /usr/bin/cekssh
chmod +x /usr/bin/cekudp

cat > /etc/cron.d/cl_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 3 * * * root /bin/cleaner
END
cat > /etc/cron.d/ba_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 1 * * * root /bin/backup
END
cat > /etc/cron.d/px_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 5 * * * root /usr/bin/px
END
cat > /etc/cron.d/re_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 5 * * * root /sbin/reboot
END
cat > /etc/cron.d/xp_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 2 * * * root /usr/bin/xp
END
cat > /etc/cron.d/cl_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 7 * * * root /usr/bin/clearlog
END
cat > /etc/cron.d/px_otm <<-END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 6 * * * root /usr/bin/px
END
cat > /home/re_otm <<-END
7
END

service cron restart >/dev/null 2>&1
service cron reload >/dev/null 2>&1
clear
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
clear
menu
END
chmod 644 /root/.profile
if [ -f "/root/log-install.txt" ]; then
rm -fr /root/log-install.txt
fi
if [ -f "/etc/afak.conf" ]; then
rm -fr /etc/afak.conf
fi
if [ ! -f "/etc/log-create-user.log" ]; then
echo "Log All Account " > /etc/log-create-user.log
fi

curl -sS ifconfig.me > /etc/myipvps

#install gotop
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
    gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v"$gotop_latest"_linux_amd64.deb"
    curl -sL "$gotop_link" -o /tmp/gotop.deb
    dpkg -i /tmp/gotop.deb >/dev/null 2>&1

# memory swap 1gb
cd
dd if=/dev/zero of=/swapfile bs=1024 count=1048576
mkswap /swapfile
chown root:root /swapfile
chmod 0600 /swapfile >/dev/null 2>&1
swapon /swapfile >/dev/null 2>&1
sed -i '$ i\/swapfile      swap swap   defaults    0 0' /etc/fstab

echo -e " Memasang Swap 2 GB"

    # Mengambil versi terbaru gotop
gotop_latest="$(curl -s https://api.github.com/repos/xxxserxxx/gotop/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
gotop_link="https://github.com/xxxserxxx/gotop/releases/download/v$gotop_latest/gotop_v${gotop_latest}_linux_amd64.deb"

    # Download & install gotop
curl -sL "$gotop_link" -o /tmp/gotop.deb
dpkg -i /tmp/gotop.deb >/dev/null 2>&1

    # Membuat swap file 2GB
dd if=/dev/zero of=/swapfile bs=1M count=2048
mkswap /swapfile
chown root:root /swapfile
chmod 0600 /swapfile
swapon /swapfile >/dev/null 2>&1

# Tambahkan swap ke fstab agar aktif saat boot
sed -i '$ i\/swapfile swap swap defaults 0 0' /etc/fstab

# Sinkronisasi waktu dengan server Indonesia
chronyd -q 'server 0.id.pool.ntp.org iburst'
chronyc sourcestats -v
chronyc tracking -v

echo -e "Swap 2 GB berhasil dipasang"

clear
echo  ""
echo  "Sukses Sayank..!!"
echo  "------------------------------------------------------------"
echo ""
echo "===============-[ Script By Arya Blitar ]-==============="
echo ""
echo  "   >>> Service & Port"  | tee -a log-install.txt
echo  "   - OpenSSH                 : 22, 2253"  | tee -a log-install.txt
echo  "   - SSH Websocket           : 80" | tee -a log-install.txt
echo  "   - SSH SSL Websocket       : 443" | tee -a log-install.txt
echo  "   - Stunnel5                : 444, 445, 447, 777" | tee -a log-install.txt
echo  "   - Dropbear                : 109, 143" | tee -a log-install.txt
echo  "   - Badvpn                  : 7100-7300" | tee -a log-install.txt
echo  "   - Nginx                   : 81" | tee -a log-install.txt
echo  "   - XRAY  Vmess TLS         : 443" | tee -a log-install.txt
echo  "   - XRAY  Vmess None TLS    : 80" | tee -a log-install.txt
echo  "   - XRAY  Vless TLS         : 443" | tee -a log-install.txt
echo  "   - XRAY  Vless None TLS    : 80" | tee -a log-install.txt
echo  "   - Trojan GRPC             : 443" | tee -a log-install.txt
echo  "   - Trojan WS               : 443" | tee -a log-install.txt
echo  ""  | tee -a log-install.txt
echo  "   >>> Server Information & Other Features"  | tee -a log-install.txt
echo  "   - Timezone                : Asia/Jakarta (GMT +7)"  | tee -a log-install.txt
echo  "   - Fail2Ban                : [ON]"  | tee -a log-install.txt
echo  "   - Dflate                  : [ON]"  | tee -a log-install.txt
echo  "   - IPtables                : [ON]"  | tee -a log-install.txt
echo  "   - Auto-Reboot             : [ON]"  | tee -a log-install.txt
echo  "   - Autoreboot              : 05.00 GMT +7" | tee -a log-install.txt
echo  "   - AutoBackup              : 01.00 GMT +7" | tee -a log-install.txt
echo  "   - AutoKill Multi Login User" | tee -a log-install.txt
echo  "   - Auto Delete Expired Account" | tee -a log-install.txt
echo  "   - Fully automatic script" | tee -a log-install.txt
echo  "   - VPS settings" | tee -a log-install.txt
echo  "   - Restore Data" | tee -a log-install.txt
echo  "   - Full Orders For Various Services" | tee -a log-install.txt
echo ""
echo "===============-[ Script By Arya Blitar ]-==============="
echo ""
echo  "------------------------------------------------------------"
echo -e "Wa Me +6281931615811"
echo  ""
echo  "" | tee -a log-install.txt
rm -fr /root/tools2.sh
rm -fr /root/wspro.sh
rm -fr /root/ssh-vpn4.sh
rm -fr /root/ins-xray.sh
rm -fr /root/main2.sh
rm -fr /root/set-br.sh
rm -fr /root/domain
history -c
echo -ne "[ ${GREEN}INFO${NC} ] Apakah Anda Ingin Reboot Sekarang ? (y/n)? "
read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
exit 0
else
reboot
fi
