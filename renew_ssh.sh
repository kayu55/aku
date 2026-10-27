#!/bin/bash
# clear # Komentari atau hapus ini

User=$1
Days=$3
iplimit=$2

IP=$(curl -sS ipv4.icanhazip.com)


# Cek apakah user ada
if id "$User" &>/dev/null; then
  current_exp=$(chage -l $User | grep "Account expires" | cut -d: -f2 | xargs)

  if [[ "$current_exp" == "never" ]]; then
    base_date=$(date +%s)
  else
    base_date=$(date -d "$current_exp" +%s)
  fi

  Days_Detailed=$(( $Days * 86400 ))
  Expire_On=$(( $base_date + $Days_Detailed ))
  Expiration=$(date -u --date="1970-01-01 $Expire_On sec GMT" +%Y/%m/%d)
  Expiration_Display=$(date -u --date="1970-01-01 $Expire_On sec GMT" '+%d %b %Y')
  
  expi=$(cat /etc/xray/ssh | grep -wE "$User" | cut -d " " -f6-8)
  sed -i "s/$expi/$Expiration_Display/" /etc/xray/ssh
  passwd -u $User &>/dev/null 
  usermod -e $Expiration $User &>/dev/null

  # Output dalam format Key : Value
  echo "Remark     : ${User}"
  echo "Limit Ip   : ${iplimit}"
  echo "Expiry in  : ${Expiration_Display}"
  exit 0
else
  echo "RENEW SSH GAGAL: User tidak ditemukan" # Output teks error
  exit 1
fi