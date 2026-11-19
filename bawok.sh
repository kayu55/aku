cat > /usr/bin/bawok <<'EOF'
#!/bin/bash
NC='\033[0;37m'
GREEN='\033[0;32m'
MB='\033[0;33m'
clear
echo -n > /tmp/other.txt
data=( $(cat /etc/xray/config.json | grep '###' | cut -d ' ' -f 2 | sort | uniq) )
echo -e "\033[0;34m┌──────────────────────────────────────────┐\033[0m"
echo -e "            ALLXRAY USER LOGIN            $NC"
echo -e "\033[0;34m└──────────────────────────────────────────┘\033[0m"
echo -e "\033[1;91m┌──────────────────────────────────────────┐\033[0m"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then akun="tidakada"; fi
echo -n > /tmp/ipvmess.txt
# FIX v25: ambil IP pake regex, ora nganggo cut -f 3 maneh
# iso moco tcp://IP, from tcp://IP, lan tcp:IP
data2=( $(cat /var/log/xray/access.log 2>/dev/null | tail -n 500 | grep -oE '(tcp://)?[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | sed 's/tcp:\/\///g' | cut -d ":" -f 1 | sort | uniq) )
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access.log 2>/dev/null | grep -w "$akun" | tail -n 500 | grep -oE '(tcp://)?[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+' | sed 's/tcp:\/\///g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvmess.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvmess.txt)
# FIX v25: lastlogin ambil 2 kolom pertama (tanggal + jam), ora mung kolom 2
lastlogin=$(cat /var/log/xray/access.log 2>/dev/null | grep -w "$akun" | tail -n 1 | awk '{print $1" "$2}')
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipvmess.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipvmess.txt | nl)
echo -e ""
echo -e "${NC}user :${GREEN} ${akun} ${NC}\n${MB}Online Jam ${NC}: ${lastlogin} wib";
echo -e "$jum2";
fi
rm -rf /tmp/ipvmess.txt
done
rm -rf /tmp/other.txt
echo -e "\033[1;91m└──────────────────────────────────────────┘\033[0m"
echo -e "${GREEN} "
echo -e " Sc Arya Blitar ${NC} "
echo -e " "
read -n 1 -s -r -p " Klik Enter Balik Ke menu"
menu
EOF
chmod +x /usr/bin/bawok