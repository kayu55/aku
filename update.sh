#!/bin/bash

GitUser="kipas77pro"
if [ "${EUID}" -ne 0 ]; then
		echo "You need to run this script as root"
		exit 1
fi
if [ "$(systemd-detect-virt)" == "openvz" ]; then
		echo "OpenVZ is not supported"
		exit 1
fi
clear
echo ""
sleep 2
echo -e "\e[1;36mStart Update For New Version, Please Wait..\e[m"
sleep 2
clear
echo -e "\e[0;32mGetting New Version Script..\e[0m"
sleep 1
echo ""
# UPDATE RUN-UPDATE
cd /usr/bin
wget -O run-update "https://raw.githubusercontent.com/${GitUser}/aku/main/options/update.sh" >/dev/null 2>&1
chmod +x run-update
# RUN UPDATE
echo ""
clear
echo -e "\e[0;32mPlease Wait...!\e[0m"
sleep 6
clear
echo ""
echo -e "\e[0;32mNew Version Downloading started!\e[0m"
sleep 2
cd /usr/bin

rm -rf menu-vless
rm -rf menu-vmess
rm -rf menu-trojan
rm -rf menu-ssh
rm -rf menu
rm -rf menu-set
rm -rf babi
rm -rf info
rm -rf add-tr
rm -rf add-vless
rm -rf add-ws
rm -rf trialssh
rm -rf trialtrojan
rm -rf trialvless
rm -rf trialvmess
rm -rf usernew

wget -q -O /usr/bin/menu-vless "https://raw.githubusercontent.com/kipas77pro/aku/main/menu/menu-vless.sh"
wget -q -O /usr/bin/menu-vmess "https://raw.githubusercontent.com/kipas77pro/aku/main/menu/menu-vmess.sh"
wget -q -O /usr/bin/menu-trojan "https://raw.githubusercontent.com/kipas77pro/aku/main/menu/menu-trojan.sh"
wget -q -O /usr/bin/menu-ssh "https://raw.githubusercontent.com/kipas77pro/aku/main/menu/menu-ssh.sh"
wget -q -O /usr/bin/menu "https://raw.githubusercontent.com/kipas77pro/aku/main/menu/menu.sh"
wget -q -O /usr/bin/menu-set "https://raw.githubusercontent.com/kipas77pro/aku/main/menu/menu-set.sh"
wget -q -O /usr/bin/babi "https://raw.githubusercontent.com/kipas77pro/aku/main/ssh/babi.sh"
wget -q -O /usr/bin/info "https://raw.githubusercontent.com/kipas77pro/aku/main/options/info.sh"
#add
wget -q -O /usr/bin/add-tr "https://raw.githubusercontent.com/kipas77pro/aku/main/add-tr.sh"
wget -q -O /usr/bin/add-vless "https://raw.githubusercontent.com/kipas77pro/aku/main/add-vless.sh"
wget -q -O /usr/bin/add-ws "https://raw.githubusercontent.com/kipas77pro/aku/main/add-ws.sh"
wget -q -O /usr/bin/trialssh "https://raw.githubusercontent.com/kipas77pro/aku/main/trialssh.sh"
wget -q -O /usr/bin/trialtrojan "https://raw.githubusercontent.com/kipas77pro/aku/main/trialtrojan.sh"
wget -q -O /usr/bin/trialvless "https://raw.githubusercontent.com/kipas77pro/aku/main/trialvless.sh"
wget -q -O /usr/bin/trialvmess "https://raw.githubusercontent.com/kipas77pro/aku/main/trialvmess.sh"
wget -q -O /usr/bin/usernew "https://raw.githubusercontent.com/kipas77pro/aku/main/usernew.sh"

chmod +x /usr/bin/menu-vless
chmod +x /usr/bin/menu-vmess
chmod +x /usr/bin/menu-trojan
chmod +x /usr/bin/menu-ssh
chmod +x /usr/bin/menu
chmod +x /usr/bin/babi
chmod +x /usr/bin/menu-set
chmod +x /usr/bin/info
chmod +x /usr/bin/add-tr
chmod +x /usr/bin/add-vless
chmod +x /usr/bin/add-ws
chmod +x /usr/bin/trialssh
chmod +x /usr/bin/trialtrojan
chmod +x /usr/bin/trialvless
chmod +x /usr/bin/trialvmess
chmod +x /usr/bin/usernew

clear
echo -e ""
echo -e "\e[0;32mDownloaded successfully!\e[0m"
echo ""
sleep 2
echo -e "\e[0;32mPatching... OK!\e[0m"
sleep 1
echo ""
echo -e "\e[0;32mSucces Update Script For New Version\e[0m"
cd
rm -f update.sh

