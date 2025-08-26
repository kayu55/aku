#!/bin/bash
clear

LOG=""
[ -e /var/log/auth.log ] && LOG="/var/log/auth.log"
[ -e /var/log/secure ] && LOG="/var/log/secure"

DB_FILE="/etc/lunatic/ssh/.ssh.db"
declare -A LOGIN_COUNT
declare -A LIMIT_IP
declare -A DAYS_LEFT

# --- Load Limit IP & Expiry from DB ---
while read -r line; do
    [[ "$line" =~ ^#ssh# ]] || continue
    user=$(echo "$line" | awk '{print $2}')
    limit=$(echo "$line" | awk '{print $3}')
    exp_date=$(echo "$line" | cut -d' ' -f4- | tr -d ',')    
    LIMIT_IP["$user"]="${limit} IP"

    if [[ -n "$exp_date" ]]; then
        exp_epoch=$(date -d "$exp_date" +%s 2>/dev/null)
        now_epoch=$(date +%s)
        if [[ $exp_epoch -ge $now_epoch ]]; then
            days=$(( (exp_epoch - now_epoch) / 86400 ))
        else
            days=0
        fi
        DAYS_LEFT["$user"]="${days} days"
    else
        DAYS_LEFT["$user"]="N/A"
    fi
done < "$DB_FILE"

# --- Dropbear ---
for pid in $(pgrep dropbear); do
    entry=$(grep "dropbear\[$pid\].*Password auth succeeded" "$LOG")
    if [[ -n "$entry" ]]; then
        user=$(echo "$entry" | sed -E "s/.*'([^']+)'.*/\1/")
        ip=$(echo "$entry" | sed -E "s/.* from ([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+).*/\1/")
        LOGIN_COUNT["$user"]+="$ip "
    fi
done

# --- OpenSSH ---
for pid in $(pgrep -f "sshd.*\[priv\]"); do
    entry=$(grep "sshd\[$pid\].*Accepted password for" "$LOG")
    if [[ -n "$entry" ]]; then
        user=$(echo "$entry" | awk '{print $9}')
        ip=$(echo "$entry" | awk '{print $11}')
        LOGIN_COUNT["$user"]+="$ip "
    fi
done

# --- Header ---
echo -e "\033[97;1m=====================================================\033[0m"
echo -e "\033[97;1m              SSH OPENVPN MONITOR ACCESS            \033[0m"
echo -e "\033[97;1m=====================================================\033[0m"
echo -e "\033[1;37m┌────────────┬──────────┬─────────────┬─────────────┐\033[0m"
printf "\033[97;1m│ %-10s │ %-8s │ %-11s │ %-11s │\033[0m\n" "LOGIN IP" "LIMIT" "USERNAME" "DAYS LEFT"
echo -e "\033[1;37m├────────────┼──────────┼─────────────┼─────────────┤\033[0m"

# --- Data ---
for user in "${!LOGIN_COUNT[@]}"; do
    iplist=($(echo "${LOGIN_COUNT[$user]}" | tr ' ' '\n' | sort -u))
    login_ip_count=${#iplist[@]}
    limit_ip="${LIMIT_IP[$user]:-N/A}"
    days_left="${DAYS_LEFT[$user]:-N/A}"
    printf "\033[97;1m│ %-10s │ %-8s │ %-11s │ %-11s │\033[0m\n" \
        "$login_ip_count IP" "$limit_ip" "$user" "$days_left"
done | sort -k3

# --- Footer ---
echo -e "\033[1;37m└────────────┴──────────┴─────────────┴─────────────┘\033[0m"
echo -e "\033[1;32m${#LOGIN_COUNT[@]} User Online\033[0m"