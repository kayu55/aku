#!/bin/bash

NC='\033[0;37m'
green='\033[0;32m' 

clear

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
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
# / / Ambil Xray Core Version Terbaru
#bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.8.15

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

# Install Xray #
# / / Ambil Xray Core Version Terbaru
latest_version="$(curl -s https://api.github.com/repos/XTLS/Xray-core/releases | grep tag_name | sed -E 's/.*"v(.*)".*/\1/' | head -n 1)"
# / / Installation Xray Core
xraycore_link="https://github.com/XTLS/Xray-core/releases/download/v$latest_version/xray-linux-64.zip"
# / / Ambil Xray Core Version Terbaru
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.8.16

# / / Make Main Directory
mkdir -p /usr/bin/xray
mkdir -p /etc/xray
mkdir -p /usr/local/etc/xray
# / / Unzip Xray Linux 64
cd `mktemp -d`
curl -sL "$xraycore_link" -o xray.zip
unzip -q xray.zip && rm -rf xray.zip
mv xray /usr/local/bin/xray
chmod +x /usr/local/bin/xray

# Random Port Xray
vless=$((RANDOM + 10000))
vmess=$((RANDOM + 10000))
trojanws=$((RANDOM + 10000))
vlessgrpc=$((RANDOM + 10000))
vmessgrpc=$((RANDOM + 10000))
trojangrpc=$((RANDOM + 10000))

# nginx xray.conf
rm -fr /etc/nginx/conf.d/xray.conf
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
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;	
             listen 8443 ssl http2 reuseport;
             listen [::]:8443 http2 reuseport;	
             listen 2096 ssl http2 reuseport;
             listen [::]:2096 http2 reuseport;	
             listen 2087 ssl http2 reuseport;
             listen [::]:2087 http2 reuseport;	
             listen 2053 ssl http2 reuseport;
             listen [::]:2053 http2 reuseport;	
             listen 2083 ssl http2 reuseport;
             listen [::]:2083 http2 reuseport;	
             server_name 127.0.0.1 localhost;
             ssl_certificate /etc/xray/xray.crt;
             ssl_certificate_key /etc/xray/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             root /home/vps/public_html;
        }
EOF
sed -i '$ ilocation /' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:700'';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /vless' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:'"$vless"';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /vmess' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:'"$vmess"';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation = /trojan-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:'"$trojanws"';' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vless-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:'"$vlessgrpc"';' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /vmess-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:'"$vmessgrpc"';' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

sed -i '$ ilocation ^~ /trojan-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:'"$trojangrpc"';' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf

# set uuid xray
uuid=$(cat /proc/sys/kernel/random/uuid)

# xray config
cat <<EOF> /etc/xray/config.json
{
  "log": {
    "access": "none",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "stats": {},
  "policy": {
    "levels": {
      "0": {
        "statsUserUplink": true,
        "statsUserDownlink": true
      }
    }
  },
  "api": {
    "tag": "a4n-api",
    "services": [
      "StatsService",
      "HandlerService"
    ]
  },
  "inbounds": [
    {
      "tag": "vmess-ws",
      "listen": "127.0.0.1",
      "port": $vmess,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "206afecb-5001-4c18-ac33-318b717ddf4b",
            "alterId": 0,
            "email": "azka-vmess-ws"
          },
          {
            "id": "fdf27eaf-304f-4170-8c88-c8444a8cfc69",
            "alterId": 0,
            "email": "beja-vmess-ws"
          },
          {
            "id": "080fa37b-d636-4f24-8411-46eba102c3e3",
            "alterId": 0,
            "email": "faisol-vmess-ws"
          },
          {
            "id": "c6f1f61e-4d6a-436f-a6dc-10582f6b0666",
            "alterId": 0,
            "email": "gufron-vmess-ws"
          },
          {
            "id": "dc86ffd7-371a-4f0a-b022-cecb4015a299",
            "alterId": 0,
            "email": "imam-vmess-ws"
          },
          {
            "id": "c7761c54-b4ac-4865-b6e0-e282d8544e3a",
            "alterId": 0,
            "email": "irfan-vmess-ws"
          },
          {
            "id": "13b93193-45d2-40ae-bf7f-e6662cb96d80",
            "alterId": 0,
            "email": "isti-vmess-ws"
          },
          {
            "id": "feb286ac-19f7-4409-aae2-7c261f9cc02a",
            "alterId": 0,
            "email": "jai-vmess-ws"
          },
          {
            "id": "7a227eb1-4c4a-40c9-9b82-fe5b9a025ffe",
            "alterId": 0,
            "email": "jali-vmess-ws"
          },
          {
            "id": "4df58be6-e4c8-44ab-beaf-9c4dfe29ad2f",
            "alterId": 0,
            "email": "jalil-vmess-ws"
          },
          {
            "id": "e215c90b-5094-4e4b-bad1-9419b6292336",
            "alterId": 0,
            "email": "karin-vmess-ws"
          },
          {
            "id": "9f3714c0-7da9-454c-b47f-7c5e0419e988",
            "alterId": 0,
            "email": "lail-vmess-ws"
          },
          {
            "id": "6c576ecc-867b-47c0-bc11-fb0840483761",
            "alterId": 0,
            "email": "muna-vmess-ws"
          },
          {
            "id": "beff1620-9f7f-4c86-ae83-1bf9251bc543",
            "alterId": 0,
            "email": "muzay-vmess-ws"
          },
          {
            "id": "0c22ba55-39a8-4141-8a63-cb3c86e9856f",
            "alterId": 0,
            "email": "naib-vmess-ws"
          },
          {
            "id": "19b82a61-a348-4744-9f05-0a022a47b9ab",
            "alterId": 0,
            "email": "qibti-vmess-ws"
          },
          {
            "id": "a37fb1e2-95e7-4626-9c39-6809e6ef965d",
            "alterId": 0,
            "email": "sabila-vmess-ws"
          },
          {
            "id": "a9a78597-1122-436b-8572-af321c8b7c85",
            "alterId": 0,
            "email": "salam-vmess-ws"
          },
          {
            "id": "8fa59676-4da1-45d7-814e-9fbe765f74da",
            "alterId": 0,
            "email": "tes-vmess-ws"
          },
          {
            "id": "94326b7c-9df0-4ffd-968a-58946a627ffe",
            "alterId": 0,
            "email": "tui-vmess-ws"
          },
          {
            "id": "292b8e9a-f154-4083-bee3-aa062425a24f",
            "alterId": 0,
            "email": "yana-vmess-ws"
          },
          {
            "id": "e874f732-f6ab-4b93-8f32-6be11c35e809",
            "alterId": 0,
            "email": "zumro-vmess-ws"
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vmess"
        }
      }
    },
    {
      "tag": "vmess-grpc",
      "listen": "127.0.0.1",
      "port": $vmess,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "206afecb-5001-4c18-ac33-318b717ddf4b",
            "alterId": 0,
            "email": "azka-vmess-grpc"
          },
          {
            "id": "fdf27eaf-304f-4170-8c88-c8444a8cfc69",
            "alterId": 0,
            "email": "beja-vmess-grpc"
          },
          {
            "id": "080fa37b-d636-4f24-8411-46eba102c3e3",
            "alterId": 0,
            "email": "faisol-vmess-grpc"
          },
          {
            "id": "c6f1f61e-4d6a-436f-a6dc-10582f6b0666",
            "alterId": 0,
            "email": "gufron-vmess-grpc"
          },
          {
            "id": "dc86ffd7-371a-4f0a-b022-cecb4015a299",
            "alterId": 0,
            "email": "imam-vmess-grpc"
          },
          {
            "id": "c7761c54-b4ac-4865-b6e0-e282d8544e3a",
            "alterId": 0,
            "email": "irfan-vmess-grpc"
          },
          {
            "id": "13b93193-45d2-40ae-bf7f-e6662cb96d80",
            "alterId": 0,
            "email": "isti-vmess-grpc"
          },
          {
            "id": "feb286ac-19f7-4409-aae2-7c261f9cc02a",
            "alterId": 0,
            "email": "jai-vmess-grpc"
          },
          {
            "id": "7a227eb1-4c4a-40c9-9b82-fe5b9a025ffe",
            "alterId": 0,
            "email": "jali-vmess-grpc"
          },
          {
            "id": "4df58be6-e4c8-44ab-beaf-9c4dfe29ad2f",
            "alterId": 0,
            "email": "jalil-vmess-grpc"
          },
          {
            "id": "e215c90b-5094-4e4b-bad1-9419b6292336",
            "alterId": 0,
            "email": "karin-vmess-grpc"
          },
          {
            "id": "9f3714c0-7da9-454c-b47f-7c5e0419e988",
            "alterId": 0,
            "email": "lail-vmess-grpc"
          },
          {
            "id": "6c576ecc-867b-47c0-bc11-fb0840483761",
            "alterId": 0,
            "email": "muna-vmess-grpc"
          },
          {
            "id": "beff1620-9f7f-4c86-ae83-1bf9251bc543",
            "alterId": 0,
            "email": "muzay-vmess-grpc"
          },
          {
            "id": "0c22ba55-39a8-4141-8a63-cb3c86e9856f",
            "alterId": 0,
            "email": "naib-vmess-grpc"
          },
          {
            "id": "19b82a61-a348-4744-9f05-0a022a47b9ab",
            "alterId": 0,
            "email": "qibti-vmess-grpc"
          },
          {
            "id": "a37fb1e2-95e7-4626-9c39-6809e6ef965d",
            "alterId": 0,
            "email": "sabila-vmess-grpc"
          },
          {
            "id": "a9a78597-1122-436b-8572-af321c8b7c85",
            "alterId": 0,
            "email": "salam-vmess-grpc"
          },
          {
            "id": "8fa59676-4da1-45d7-814e-9fbe765f74da",
            "alterId": 0,
            "email": "tes-vmess-grpc"
          },
          {
            "id": "94326b7c-9df0-4ffd-968a-58946a627ffe",
            "alterId": 0,
            "email": "tui-vmess-grpc"
          },
          {
            "id": "292b8e9a-f154-4083-bee3-aa062425a24f",
            "alterId": 0,
            "email": "yana-vmess-grpc"
          },
          {
            "id": "e874f732-f6ab-4b93-8f32-6be11c35e809",
            "alterId": 0,
            "email": "zumro-vmess-grpc"
          }
        ]
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "vmess",
          "multiMode": false
        }
      }
    },
    {
      "tag": "vmess-httpupgrade",
      "listen": "127.0.0.1",
      "port": $vmess,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "206afecb-5001-4c18-ac33-318b717ddf4b",
            "alterId": 0,
            "email": "azka-vmess-httpupgrade"
          },
          {
            "id": "fdf27eaf-304f-4170-8c88-c8444a8cfc69",
            "alterId": 0,
            "email": "beja-vmess-httpupgrade"
          },
          {
            "id": "080fa37b-d636-4f24-8411-46eba102c3e3",
            "alterId": 0,
            "email": "faisol-vmess-httpupgrade"
          },
          {
            "id": "c6f1f61e-4d6a-436f-a6dc-10582f6b0666",
            "alterId": 0,
            "email": "gufron-vmess-httpupgrade"
          },
          {
            "id": "dc86ffd7-371a-4f0a-b022-cecb4015a299",
            "alterId": 0,
            "email": "imam-vmess-httpupgrade"
          },
          {
            "id": "c7761c54-b4ac-4865-b6e0-e282d8544e3a",
            "alterId": 0,
            "email": "irfan-vmess-httpupgrade"
          },
          {
            "id": "13b93193-45d2-40ae-bf7f-e6662cb96d80",
            "alterId": 0,
            "email": "isti-vmess-httpupgrade"
          },
          {
            "id": "feb286ac-19f7-4409-aae2-7c261f9cc02a",
            "alterId": 0,
            "email": "jai-vmess-httpupgrade"
          },
          {
            "id": "7a227eb1-4c4a-40c9-9b82-fe5b9a025ffe",
            "alterId": 0,
            "email": "jali-vmess-httpupgrade"
          },
          {
            "id": "4df58be6-e4c8-44ab-beaf-9c4dfe29ad2f",
            "alterId": 0,
            "email": "jalil-vmess-httpupgrade"
          },
          {
            "id": "e215c90b-5094-4e4b-bad1-9419b6292336",
            "alterId": 0,
            "email": "karin-vmess-httpupgrade"
          },
          {
            "id": "9f3714c0-7da9-454c-b47f-7c5e0419e988",
            "alterId": 0,
            "email": "lail-vmess-httpupgrade"
          },
          {
            "id": "6c576ecc-867b-47c0-bc11-fb0840483761",
            "alterId": 0,
            "email": "muna-vmess-httpupgrade"
          },
          {
            "id": "beff1620-9f7f-4c86-ae83-1bf9251bc543",
            "alterId": 0,
            "email": "muzay-vmess-httpupgrade"
          },
          {
            "id": "0c22ba55-39a8-4141-8a63-cb3c86e9856f",
            "alterId": 0,
            "email": "naib-vmess-httpupgrade"
          },
          {
            "id": "19b82a61-a348-4744-9f05-0a022a47b9ab",
            "alterId": 0,
            "email": "qibti-vmess-httpupgrade"
          },
          {
            "id": "a37fb1e2-95e7-4626-9c39-6809e6ef965d",
            "alterId": 0,
            "email": "sabila-vmess-httpupgrade"
          },
          {
            "id": "a9a78597-1122-436b-8572-af321c8b7c85",
            "alterId": 0,
            "email": "salam-vmess-httpupgrade"
          },
          {
            "id": "8fa59676-4da1-45d7-814e-9fbe765f74da",
            "alterId": 0,
            "email": "tes-vmess-httpupgrade"
          },
          {
            "id": "94326b7c-9df0-4ffd-968a-58946a627ffe",
            "alterId": 0,
            "email": "tui-vmess-httpupgrade"
          },
          {
            "id": "292b8e9a-f154-4083-bee3-aa062425a24f",
            "alterId": 0,
            "email": "yana-vmess-httpupgrade"
          },
          {
            "id": "e874f732-f6ab-4b93-8f32-6be11c35e809",
            "alterId": 0,
            "email": "zumro-vmess-httpupgrade"
          }
        ]
      },
      "streamSettings": {
        "network": "httpupgrade",
        "security": "none",
        "httpupgradeSettings": {
          "path": "/upvmess"
        }
      }
    },
    {
      "tag": "trojan-ws",
      "listen": "127.0.0.1",
      "port": $trojan,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/trojan"
        }
      }
    },
    {
      "tag": "trojan-grpc",
      "listen": "127.0.0.1",
      "port": $trojan,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "trojan",
          "multiMode": false
        }
      }
    },
    {
      "tag": "trojan-httpupgrade",
      "listen": "127.0.0.1",
      "port": $trojan,
      "protocol": "trojan",
      "settings": {
        "clients": []
      },
      "streamSettings": {
        "network": "httpupgrade",
        "security": "none",
        "httpupgradeSettings": {
          "path": "/uptrojan"
        }
      }
    },
    {
      "tag": "vless-ws",
      "listen": "127.0.0.1",
      "port": $vless-ws,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "wsSettings": {
          "path": "/vless"
        }
      }
    },
    {
      "tag": "vless-grpc",
      "listen": "127.0.0.1",
      "port": $vless-grpc,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "grpc",
        "security": "none",
        "grpcSettings": {
          "serviceName": "vless",
          "multiMode": false
        }
      }
    },
    {
      "tag": "vless-httpupgrade",
      "listen": "127.0.0.1",
      "port": $vless,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "httpupgrade",
        "security": "none",
        "httpupgradeSettings": {
          "path": "/upvless"
        }
      }
    },
    {
      "tag": "a4n-api",
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": {
        "address": "127.0.0.1"
      }
    },
    {
      "tag": "vless-reality",
      "listen": "0.0.0.0",
      "port": $vless,
      "protocol": "vless",
      "settings": {
        "clients": [],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "raw",
        "security": "reality",
        "realitySettings": {
          "show": false,
          "target": "www.microsoft.com:443",
          "xver": 0,
          "serverNames": [
            "www.microsoft.com"
          ],
          "privateKey": "8FQ4n6uBwIafgLZoMxT5lC5Ty8b2VussTyrQz6ct5Hc",
          "minClientVer": "1.8.0",
          "maxTimeDiff": 0,
          "shortIds": [
            "c1209b53490143bd"
          ]
        }
      }
    }
  ],
  "outbounds": [
    {
      "tag": "direct",
      "protocol": "freedom",
      "settings": {}
    }
  ],
  "routing": {
    "domainStrategy": "AsIs",
    "rules": [
      {
        "type": "field",
        "inboundTag": [
          "a4n-api"
        ],
        "outboundTag": "a4n-api"
      }
    ]
  }
}
EOF
# Installing Xray Service
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install --beta
rm -fr /etc/systemd/system/xray.service.d
rm -fr /etc/systemd/system/xray.service
cat <<EOF> /etc/systemd/system/xray.service
Description=Xray Service
Documentation=https://github.com/xtls
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
systemctl status xray


cd /usr/bin
rm -fr upray