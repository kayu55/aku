#!/bin/bash

NC='\033[0;37m'
green='\033[0;32m' 

clear
clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi
sleep 2
ARCH=$(uname -m)
case "$ARCH" in
    x86_64|amd64)
        ARCH_TYPE="x86_64"
        ARCH_XRAY="64"
        ARCH_GOTOP="linux_amd64.deb"
        ;;
    aarch64|arm64)
        ARCH_TYPE="arm64"
        ARCH_XRAY="arm64-v8a"
        ARCH_GOTOP="linux_arm64.deb"
        ;;
    armv7*|armv6*|armhf|arm)
        ARCH_TYPE="arm"
        ARCH_XRAY="arm32-v7a"
        ARCH_GOTOP="linux_arm.deb"
        ;;
    i386|i686)
        ARCH_TYPE="i386"
        ARCH_XRAY="32"
        ARCH_GOTOP="linux_386.deb"
        ;;
    *)
        echo -e "${BIWhite} Your Architecture Is Not Supported ( ${BIYellow}$ARCH ${BIWhite})${NC}"
        exit 1
        ;;
esac

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
# Make Folder XRay
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
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

# Make Folder & Log XRay & Log Trojan
rm -fr /var/log/xray
#rm -fr /var/log/trojan
rm -fr /home/vps/public_html
mkdir -p /var/log/xray
#mkdir -p /var/log/trojan
mkdir -p /home/vps/public_html
chown www-data.www-data /var/log/xray
chown www-data.www-data /etc/xray
chmod +x /var/log/xray
#chmod +x /var/log/trojan
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
chown -R www-data:www-data /var/log/xray
chmod 755 /var/log/xray
chmod 640 /var/log/xray/*.log
# Make Log Autokill & Log Autoreboot
rm -fr /root/log-limit.txt
rm -fr /root/log-reboot.txt
touch /root/log-limit.txt
touch /root/log-reboot.txt
touch /home/limit
echo "" > /root/log-limit.txt
echo "" > /root/log-reboot.txt

# nginx for debian & ubuntu
install_ssl(){
    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            else
                    apt-get install -y nginx certbot
                    apt install -y nginx certbot
                    sleep 3s
            fi
    else
        yum install -y nginx certbot
        sleep 3s
    fi

    systemctl stop nginx.service

    if [ -f "/usr/bin/apt-get" ];then
            isDebian=`cat /etc/issue|grep Debian`
            if [ "$isDebian" != "" ];then
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            else
                    echo "A" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
                    sleep 3s
            fi
    else
        echo "Y" | certbot certonly --renew-by-default --register-unsafely-without-email --standalone -d $domain
        sleep 3s
    fi
}

# install nginx
apt install -y nginx
cd
rm -fr /etc/nginx/sites-enabled/default
rm -fr /etc/nginx/sites-available/default
wget -q -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/nginx.conf" 
#mkdir -p /home/vps/public_html
wget -q -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/kayu55/aku/main/tools/vps.conf"

#intall vray 
clear
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir
mkdir -p /usr/local/share/xray /usr/local/bin
if [ "$ARCH_TYPE" = "x86_64" ]; then
    wget -q -O /tmp/xray.zip "${REPO}limit/xray.zip"
else
    wget -q -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/download/1.8.23/Xray-linux-${ARCH_XRAY}.zip" || \
    wget -q -O /tmp/xray.zip "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${ARCH_XRAY}.zip"
fi
if [ -f /tmp/xray.zip ]; then
    unzip -o /tmp/xray.zip -d /tmp/xray_ext/ >/dev/null 2>&1
    mv -f /tmp/xray_ext/xray /usr/local/bin/xray 2>/dev/null || true
    mv -f /tmp/xray_ext/*.dat /usr/local/share/xray/ 2>/dev/null || true
    rm -rf /tmp/xray.zip /tmp/xray_ext
fi
if [ ! -f /usr/local/bin/xray ]; then
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --version 1.8.23 || true
fi
chmod +x /usr/local/bin/xray


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
systemctl start nginx >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1
# Restart All Service
echo -e "$yell[SERVICE]$NC Restart All Service"
chown -R www-data:www-data /home/vps/public_html
# Enable & Restart & Xray & Trojan & Nginx
echo -e "[ ${GREEN}ok${NC} ] Restart & Xray & Nginx"
systemctl daemon-reload >/dev/null 2>&1
systemctl restart xray >/dev/null 2>&1
systemctl restart nginx >/dev/null 2>&1

cd /usr/bin
rm -fr upray