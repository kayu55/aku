#!/bin/bash

if [ "${EUID}" -ne 0 ]; then
echo -e "${EROR} Please Run This Script As Root User !"
exit 1
fi
clear
sleep 1

echo -e "${GREEN}Download Data Menu${NC}"
wget -q -O /usr/bin/cekssh "https://raw.githubusercontent.com/kayu55/aku/main/cekssh.sh"
wget -q -O /usr/bin/usernew "https://raw.githubusercontent.com/kayu55/aku/main/usernew.sh"
wget -q -O /usr/bin/trialssh "https://raw.githubusercontent.com/kayu55/aku/main/trialssh.sh"
wget -q -O /usr/bin/add-ws "https://raw.githubusercontent.com/kayu55/aku/main/add-ws.sh"
wget -q -O /usr/bin/trialvmess "https://raw.githubusercontent.com/kayu55/aku/main/trialvmess.sh"
wget -q -O /usr/bin/add-vless "https://raw.githubusercontent.com/kayu55/aku/main/add-vless.sh"
wget -q -O /usr/bin/trialvless "https://raw.githubusercontent.com/kayu55/aku/main/trialvless.sh"
wget -q -O /usr/bin/add-tr "https://raw.githubusercontent.com/kayu55/aku/main/add-tr.sh"
wget -q -O /usr/bin/trialtrojan "https://raw.githubusercontent.com/kayu55/aku/main/trialtrojan.sh"
wget -q -O /usr/bin/autoreboot "https://raw.githubusercontent.com/kayu55/aku/main/options/autoreboot.sh"
wget -q -O /usr/bin/restart "https://raw.githubusercontent.com/kayu55/aku/main/options/restart.sh"
wget -q -O /usr/bin/tendang "https://raw.githubusercontent.com/kayu55/aku/main/options/tendang.sh"
wget -q -O /usr/bin/clearlog "https://raw.githubusercontent.com/kayu55/aku/main/options/clearlog.sh"
wget -q -O /usr/bin/running "https://raw.githubusercontent.com/kayu55/aku/main/options/running.sh"
wget -q -O /usr/bin/speedtest "https://raw.githubusercontent.com/kayu55/aku/main/tools/speedtest_cli.py"
wget -q -O /usr/bin/cek-bandwidth "https://raw.githubusercontent.com/kayu55/aku/main/options/cek-bandwidth.sh"
wget -q -O /usr/bin/menu-vless "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-vless.sh"
wget -q -O /usr/bin/menu-vmess "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-vmess.sh"
wget -q -O /usr/bin/menu-trojan "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-trojan.sh"
wget -q -O /usr/bin/menu-ssh "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-ssh.sh"
wget -q -O /usr/bin/menu-backup "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-backup.sh"
wget -q -O /usr/bin/menu "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu.sh"
wget -q -O /usr/bin/xp "https://raw.githubusercontent.com/kayu55/aku/main/xp.sh"
wget -q -O /usr/bin/addhost "https://raw.githubusercontent.com/kayu55/aku/main/menu/addhost.sh"
wget -q -O /usr/bin/certxray "https://raw.githubusercontent.com/kayu55/aku/main/menu/cf.sh"
wget -q -O /usr/bin/menu-set "https://raw.githubusercontent.com/kayu55/aku/main/menu/menu-set.sh"
#wget -q -O /usr/bin/info "https://raw.githubusercontent.com/kayu55/aku/main/options/info.sh"
#wget -q -O /usr/bin/jam "https://raw.githubusercontent.com/kayu55/aku/main/tools/jam.sh"
wget -q -O /usr/bin/babi "https://raw.githubusercontent.com/kayu55/aku/main/ssh/babi.sh"
#wget -q -O /usr/bin/update-xray "https://raw.githubusercontent.com/kayu55/aku/main/tools/update-xray.sh"
#wget -q -O /usr/bin/set-bw "https://raw.githubusercontent.com/kayu55/aku/main/options/set-bw.sh"

#chmod +x /usr/bin/jam
chmod +x /usr/bin/cekssh
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
#chmod +x /usr/bin/info
#chmod +x /usr/bin/set-bw

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
0 3 * * * root /usr/bin/clearlog
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
    
clear
#print_install "Memasang Swap 2 GB"

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
echo  "Wa Me +6281931615811"
echo  ""
echo  "" | tee -a log-install.txt
rm -fr /root/vnstat.sh
rm -fr /root/ssh-vpn.sh
rm -fr /root/ins-xray.sh
rm -fr /root/setup.sh
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