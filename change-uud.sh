#!/bin/bash

NC='\033[0;37m' 
clear
source /var/lib/scrz-prem/ipvps.conf
if [[ "$IP" = "" ]]; then
domain=$(cat /etc/xray/domain)
else
domain=$IP
fi

    clear
    echo -e "${orange}══════════════════════════════════════════════════════════════════════${neutral}"
    echo -e "${green}${bold_white}                     CUSTOM UUID VMESS${neutral}"
    echo -e "${orange}══════════════════════════════════════════════════════════════════════${neutral}"

    if [ ! -e "/etc/xray/vmess/.vmess.db" ]; then
        echo -e "   ${red}Tidak ada akun VMESS yang terdaftar.${neutral}"
        echo -e "${orange}══════════════════════════════════════════════════════════════════════${neutral}"
        echo -e " Tekan Enter untuk kembali ke menu..."
        read
        display_vmess_menu
        return
    fi

    account_count=$(grep -cE "^### " "/etc/xray/vmess/.vmess.db")
    if [ $account_count -eq 0 ]; then
        echo -e "   ${red}Tidak ada akun VMESS yang aktif.${neutral}"
        echo -e "${orange}══════════════════════════════════════════════════════════════════════${neutral}"
        echo -e " Tekan Enter untuk kembali ke menu..."
        read
        display_vmess_menu
        return
    fi
    
    echo -e "No  | Username           | Exp (hari)"
    echo -e "─────────────────────────────────────────────"
    grep -E "^### " "/etc/xray/vmess/.vmess.db" | awk '{
        cmd = "date -d \"" $3 "\" +%s"
        cmd | getline exp_timestamp
        close(cmd)
        current_timestamp = systime()
        days_left = int((exp_timestamp - current_timestamp) / 86400)
        if (days_left < 0) days_left = 0
        printf "%-3d | %-18s | %-10s\n", NR, $2, days_left " hari"
    }'
    echo -e "─────────────────────────────────────────────"
    echo -e ""
    read -p " Pilih nomor akun [ 1-$account_count ] atau [ x ] untuk batal: " account_number

    if [[ "$account_number" =~ ^[xX]$ ]]; then
        echo -e ""
        echo -e "${yellow}Batal mengubah UUID. Kembali ke menu...${neutral}"
        echo -e ""
        display_vmess_menu
        return
    fi
    
    # Check if input is a number
    if ! [[ "$account_number" =~ ^[0-9]+$ ]]; then
        echo -e "   ${red}Error: Input harus berupa angka.${neutral}"
        echo -e " Tekan Enter untuk kembali ke menu..."
        read
        display_vmess_menu
        return
    fi
    
    # Check if account number is valid
    if [ "$account_number" -lt 1 ] || [ "$account_number" -gt "$account_count" ]; then
        echo -e "   ${red}Error: Nomor akun tidak valid.${neutral}"
        echo -e " Tekan Enter untuk kembali ke menu..."
        read
        display_vmess_menu
        return
    fi

    user=$(grep -E "^### " "/etc/xray/vmess/.vmess.db" | cut -d ' ' -f 2 | sed -n "${account_number}p")

    if [ -z "$user" ]; then
        echo -e "   ${red}Nomor akun tidak valid.${neutral}"
        echo -e " Tekan Enter untuk kembali ke menu..."
        read
        display_vmess_menu
        return
    fi
    
    echo -e ""
    echo -e "Mengubah UUID untuk akun: ${green}$user${neutral}"
    echo -e ""
    while true; do
        read -p " UUID baru (minimal 6 karakter): " new_uuid
        if [[ ${#new_uuid} -ge 6 && "$new_uuid" =~ ^[a-zA-Z0-9_-]+$ ]]; then
            break
        else
            echo -e "${red} UUID harus minimal 6 karakter dan hanya boleh berisi huruf, angka, _ atau -${neutral}"
        fi
    done

    if [ -z "$new_uuid" ]; then
        echo -e "${red}Error: UUID tidak boleh kosong.${neutral}"
        echo -e " Tekan Enter untuk kembali ke menu..."
        read
        display_vmess_menu
        return
    fi

    # Update UUID in config.json
    user_data=$(cat /etc/xray/vmess/.vmess.db | grep "^### $user")
    exp=$(echo "$user_data" | awk '{print $3}')
    config_file="/etc/xray/vmess/config.json"
    db_file="/etc/xray/vmess/.vmess.db"

    sed -i "/^### $user $exp/,/^},{/d" "$config_file"

    # Add configuration back to config_file
    sed -i '/#vmess$/a\### '"$user $exp"'\
},{"id": "'""$new_uuid""'","email": "'""$user""'"'  "$config_file"

    sed -i '/#vmessgrpc$/a\### '"$user $exp"'\
},{"id": "'""$new_uuid""'","email": "'""$user""'"'  "$config_file"
  
    sed -i "/^### $user/d" "$db_file"
    echo "### $user $exp $new_uuid" >> "$db_file"
    systemctl restart vmess@config

    echo -e ""
    if [ $? -eq 0 ]; then
        echo -e "${green}UUID untuk akun $user berhasil diubah.${neutral}"
        echo -e "UUID baru: ${green}$new_uuid${neutral}"
    else
        echo -e "${red}Gagal mengubah UUID untuk akun $user.${neutral}"
        echo -e "Pastikan Anda memiliki izin yang cukup dan coba lagi."
    fi

    echo -e ""
    echo -e "${orange}══════════════════════════════════════════════════════════════════════${neutral}"
    read -n 1 -s -r -p "Tekan [ Enter ] untuk kembali ke menu..."
    echo -e ""
    display_menu-vmess