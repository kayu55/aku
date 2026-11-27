#!/bin/bash
# =========================================
# Quick Setup | Script Setup Manager
# Edition : Stable Edition - FINAL FIX BadVPN + Torrent Enteng
# (C) Copyright 2025
# =========================================

clear
BIBlack='\033[1;90m'
BIRed='\033[1;91m'
BIGreen='\033[1;92m'
BIYellow='\033[1;93m'
BIBlue='\033[1;94m'
BIPurple='\033[1;95m'
BICyan='\033[1;96m'
BIWhite='\033[1;97m'
UWhite='\033[4;37m'
On_IPurple='\033[0;105m'
On_IRed='\033[0;101m'
IBlack='\033[0;90m'
IRed='\033[0;91m'
IGreen='\033[0;92m'
IYellow='\033[0;93m'
IBlue='\033[0;94m'
IPurple='\033[0;95m'
ICyan='\033[0;96m'
IWhite='\033[0;97m'
NC='\e[0m'

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[0;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export LIGHT='\033[0;37m'
export NC='\033[0m'

export EROR="[${RED} EROR ${NC}]"
export INFO="[${YELLOW} INFO ${NC}]"
export OKEY="[${GREEN} OKEY ${NC}]"
export PENDING="[${YELLOW} PENDING ${NC}]"
export SEND="[${YELLOW} SEND ${NC}]"
export RECEIVE="[${YELLOW} RECEIVE ${NC}]"

export BOLD="\e[1m"
export WARNING="${RED}\e[5m"
export UNDERLINE="\e[4m"

export DEBIAN_FRONTEND=noninteractive
MYIP=$(curl -sS ifconfig.me);
MYIP2="s/xxxxxxxxx/$MYIP/g";
NET=$(ip -o $ANU -4 route show to default | awk '{print $5}');
source /etc/os-release
ver=$VERSION_ID

country=ID
state=Indonesia
locality=Indonesia
organization=JawaTimur
organizationalunit=Udanawu
commonname=AryaBlitar081931615811
email=setyaaries9@gmail.com

wget -q -O /etc/pam.d/common-password "https://raw.githubusercontent.com/kayu55/aku/main/tools/password"
chmod +x /etc/pam.d/common-password
cd
clear
wget -q -O /usr/local/bin/ws-stunnel "https://raw.githubusercontent.com/kayu55/aku/main/tools/ws-stunnel"
chmod +x /usr/local/bin/ws-stunnel

cat > /etc/systemd/system/ws-stunnel.service << END
[Unit]
Description=Ovpn Websocket AryaStore Blitar
Documentation=https://aryavpnstore.biz.id
After=network.target nss-lookup.target
[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/bin/python2 -O /usr/local/bin/ws-stunnel
Restart=on-failure
[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload >/dev/null 2>&1
systemctl enable ws-stunnel >/dev/null 2>&1
systemctl start ws-stunnel >/dev/null 2>&1
systemctl restart ws-stunnel >/dev/null 2>&1
clear
cd

cat > /etc/systemd/system/rc-local.service <<-END
[Unit]
Description=/etc/rc.local
ConditionPathExists=/etc/rc.local
[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=tty
RemainAfterExit=yes
SysVStartPriority=99
[Install]
WantedBy=multi-user.target
END

cat > /etc/rc.local <<-END
#!/bin/sh -e
# rc.local
# By default this script does nothing.
exit 0
END

chmod +x /etc/rc.local
echo -e "
"
date
echo ""
sleep 1
echo -e "[ ${green}INFO${NC} ] Checking... "
sleep 2
sleep 1
echo -e "[ ${green}INFO$NC ] Enable system rc local"
systemctl enable rc-local >/dev/null 2>&1
systemctl start rc-local.service >/dev/null 2>&1

sleep 1
echo -e "[ ${green}INFO$NC ] Disable ipv6"
echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6 >/dev/null 2>&1
sed -i '$ i\echo 1 > /proc/sys/net/ipv6/conf/all/disable_ipv6' /etc/rc.local >/dev/null 2>&1

sleep 1
echo -e "[ ${green}INFO$NC ] Set zona local time to Asia/Jakarta GMT+7"
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
sed -i 's/AcceptEnv/#AcceptEnv/g' /etc/ssh/sshd_config

# install badvpn
tesmatch=`screen -list | awk  '{print $1}' | grep -ow "badvpn" | sort | uniq`
if [ "$tesmatch" = "badvpn" ]; then
sleep 1
echo -e "[ ${green}INFO$NC ] Screen badvpn detected"
rm /root/screenlog > /dev/null 2>&1
    runningscreen=( `screen -list | awk  '{print $1}' | grep -w "badvpn"` )
    for actv in "${runningscreen[@]}"
    do
        cek=( `screen -list | awk  '{print $1}' | grep -w "badvpn"` )
        if [ "$cek" = "$actv" ]; then
        for sama in "${cek[@]}"; do
            sleep 1
            screen -XS $sama quit > /dev/null 2>&1
            echo -e "[ ${red}CLOSE$NC ] Closing screen $sama"
        done 
        fi
    done
else
echo -ne
fi
cd
echo -e "[ ${green}INFO$NC ] Installing badvpn for game support..."
wget -q -O /usr/bin/badvpn-udpgw "https://raw.githubusercontent.com/kayu55/aku/main/tools/newudpgw"
chmod +x /usr/bin/badvpn-udpgw  >/dev/null 2>&1
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000' /etc/rc.local >/dev/null 2>&1
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000' /etc/rc.local >/dev/null 2>&1
sed -i '$ i\screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000' /etc/rc.local >/dev/null 2>&1
systemctl daemon-reload >/dev/null 2>&1
systemctl start rc-local.service >/dev/null 2>&1
systemctl restart rc-local.service >/dev/null 2>&1

sed -i 's/Port 22/Port 22/g' /etc/ssh/sshd_config
sed -i '/Port 22/a Port 2253' /etc/ssh/sshd_config
echo "Port 22" >> /etc/ssh/sshd_config
echo "Port 40000" >> /etc/ssh/sshd_config
echo "X11Forwarding yes" >> /etc/ssh/sshd_config
echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
echo "PubkeyAuthentication yes" >> /etc/ssh/sshd_config
echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
sed -i 's/#AllowTcpForwarding yes/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl daemon-reload >/dev/null 2>&1
systemctl start ssh >/dev/null 2>&1
systemctl restart ssh >/dev/null 2>&1

sleep 1
echo -e "[ ${green}INFO$NC ] Settings Dropbear"
sed -i 's/NO_START=1/NO_START=0/g' /etc/default/dropbear
sed -i 's/DROPBEAR_PORT=22/DROPBEAR_PORT=143/g' /etc/default/dropbear
sed -i 's/DROPBEAR_EXTRA_ARGS=/DROPBEAR_EXTRA_ARGS="-p 109"/g' /etc/default/dropbear
systemctl daemon-reload >/dev/null 2>&1
systemctl start dropbear >/dev/null 2>&1
systemctl restart dropbear >/dev/null 2>&1
cekker=$(cat /etc/shells | grep -w "/bin/false")
if [[ "$cekker" = "/bin/false" ]];then
echo -ne
else
echo "/bin/false" >> /etc/shells
echo "/usr/sbin/nologin" >> /etc/shells
fi



sleep 1
echo -e "[ ${green}INFO$NC ] Install bbr"
Add_To_New_Line(){
	if [ "$(tail -n1 $1 | wc -l)" == "0"  ];then
		echo "" >> "$1"
	fi
	echo "$2" >> "$1"
}
Check_And_Add_Line(){
	if [ -z "$(cat "$1" | grep "$2")" ];then
		Add_To_New_Line "$1" "$2"
	fi
}
Install_BBR(){
echo "#############################################"
echo "Install TCP_BBR..."
if [ -n "$(lsmod | grep bbr)" ];then
echo "TCP_BBR sudah diinstall."
echo "#############################################"
return 1
fi
echo "Mulai menginstall TCP_BBR..."
modprobe tcp_bbr
Add_To_New_Line "/etc/modules-load.d/modules.conf" "tcp_bbr"
Add_To_New_Line "/etc/sysctl.conf" "net.core.default_qdisc = fq"
Add_To_New_Line "/etc/sysctl.conf" "net.ipv4.tcp_congestion_control = bbr"
sysctl -p
if [ -n "$(sysctl net.ipv4.tcp_available_congestion_control | grep bbr)" ] && [ -n "$(sysctl net.ipv4.tcp_congestion_control | grep bbr)" ] && [ -n "$(lsmod | grep "tcp_bbr")" ];then
	echo "TCP_BBR Install Success."
else
	echo "Gagal menginstall TCP_BBR."
fi
echo "#############################################"
}
Optimize_Parameters(){
echo "#############################################"
echo "Optimasi Parameters..."
Check_And_Add_Line "/etc/security/limits.conf" "* soft nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "* hard nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "root soft nofile 51200"
Check_And_Add_Line "/etc/security/limits.conf" "root hard nofile 51200"
Check_And_Add_Line "/etc/sysctl.conf" "fs.file-max = 51200"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.rmem_max = 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.wmem_max = 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.netdev_max_backlog = 250000"
Check_And_Add_Line "/etc/sysctl.conf" "net.core.somaxconn = 4096"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_syncookies = 1"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_tw_reuse = 1"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fin_timeout = 30"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_keepalive_time = 1200"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.ip_local_port_range = 10000 65000"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_syn_backlog = 8192"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_max_tw_buckets = 5000"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_fastopen = 3"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mem = 25600 51200 102400"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_rmem = 4096 87380 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_wmem = 4096 65536 67108864"
Check_And_Add_Line "/etc/sysctl.conf" "net.ipv4.tcp_mtu_probing = 1"
echo "Optimasi Parameters Selesai."
echo "#############################################"
}
Install_BBR
Optimize_Parameters
sleep 1
echo -e "[ ${green}INFO$NC ] Install successfully..."

cd
dd if=/dev/zero of=/swapfile bs=1024 count=1048576
mkswap /swapfile
chown root:root /swapfile
chmod 0600 /swapfile >/dev/null 2>&1
swapon /swapfile >/dev/null 2>&1
sed -i '$ i\/swapfile      swap swap   defaults    0 0' /etc/fstab

apt -y install fail2ban
sudo systemctl enable --now fail2ban
/etc/init.d/fail2ban restart
/etc/init.d/fail2ban status
rm -fr /usr/local/ddos
mkdir -p /usr/local/ddos >/dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Install DOS-Deflate"
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading source files..."
wget -q -O /usr/local/ddos/ddos.conf http://www.inetbase.com/scripts/ddos/ddos.conf
wget -q -O /usr/local/ddos/LICENSE http://www.inetbase.com/scripts/ddos/LICENSE
wget -q -O /usr/local/ddos/ignore.ip.list http://www.inetbase.com/scripts/ddos/ignore.ip.list
wget -q -O /usr/local/ddos/ddos.sh http://www.inetbase.com/scripts/ddos/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos  >/dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Create cron script every minute...."
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
sleep 1
echo -e "[ ${green}INFO$NC ] Install successfully..."
sleep 1
echo -e "[ ${green}INFO$NC ] Config file at /usr/local/ddos/ddos.conf"

rm -fr /etc/issue.net
rm -fr /etc/issue.net.save
sleep 1
echo -e "[ ${green}INFO$NC ] Settings banner"
wget -q -O /etc/issue.net "https://raw.githubusercontent.com/kayu55/aku/main/ssh/issue.net"
chmod +x /etc/issue.net
echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
sed -i 's@DROPBEAR_BANNER=""@DROPBEAR_BANNER="/etc/issue.net"@g' /etc/default/dropbear

# Blokir Torrent - Versi Enteng (FIXED - Tanpa --string, Ping Cilik)
echo -e "[ ${green}INFO$NC ] Set iptables - Anti Torrent Enteng"
sleep 1
sudo iptables -A FORWARD -p tcp --dport 6881:6889 -j DROP
sudo iptables -A FORWARD -p udp --dport 6881:6889 -j DROP
sudo iptables -A FORWARD -p tcp --dport 6969 -j DROP
sudo iptables -A FORWARD -p udp --dport 6969 -j DROP
sudo iptables-save > /etc/iptables.up.rules
sudo netfilter-persistent save >/dev/null 2>&1
sudo netfilter-persistent reload >/dev/null 2>&1

echo "/bin/false" >>/etc/shells
echo "/usr/sbin/nologin" >>/etc/shells
cat >/etc/rc.local <<EOF
#!/bin/sh -e
# rc.local
# By default this script does nothing.
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
systemctl restart netfilter-persistent
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000
exit 0
EOF

sleep 1
echo -e "[ ${green}INFO$NC ] Clearing trash"
apt autoclean -y >/dev/null 2>&1
if dpkg -s unscd >/dev/null 2>&1; then
apt -y remove --purge unscd >/dev/null 2>&1
fi

cd
echo -e "[ ${green}ok${NC} ] Restarting Cron"
/etc/init.d/cron restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting Ssh"
/etc/init.d/ssh restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting Dropbear"
/etc/init.d/dropbear restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting Fail2ban"
/etc/init.d/fail2ban restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting Stunnel5"
/etc/init.d/stunnel5 restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting Vnstat"
/etc/init.d/vnstat restart >/dev/null 2>&1
sleep 1
echo -e "[ ${green}ok${NC} ] Restarting squid "
pkill badvpn-udpgw >/dev/null 2>&1; sleep 1
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100 --max-clients 1000 >/dev/null 2>&1
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200 --max-clients 1000 >/dev/null 2>&1
screen -dmS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 1000 >/dev/null 2>&1
history -c
echo "unset HISTFILE" >> /etc/profile
cd
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
sleep 1
yellow "SSH & OVPN install successfully"
sleep 5
clear
rm -fr /root/key.pem >/dev/null 2>&1
rm -fr /root/cert.pem >/dev/null 2>&1
rm -fr /root/ssh-vpn.sh >/dev/null 2>&1