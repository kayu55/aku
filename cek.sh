#!/bin/bash
# SSH / OpenVPN Monitor Access (riwayat login & live sessions)
# Mode:
#   default  -> hitung IP unik dari login sukses di log (riwayat terbaru)
#   --live   -> hitung sesi yang SEDANG aktif (who/ps)

set -euo pipefail
clear

MODE="${1:-history}"   # "history" | "--live"
[ "$MODE" = "--live" ] && MODE="live"
DEBUG="${DEBUG:-0}"

DB_FILE="/etc/scrz-prem/ssh/.ssh.db"

declare -A LOGIN_COUNT   # user -> "ip ip ip ..."
declare -A ONLINE_IPS    # user -> "ip ip ip ..."
declare -A LIMIT_IP      # user -> "N IP"
declare -A DAYS_LEFT     # user -> "X days"

# --- Pilih file log yang ada & terbaca ---
LOG=""
for CAND in /var/log/auth.log /var/log/secure /var/log/messages; do
  [ -r "$CAND" ] && LOG="$CAND" && break
done

# --- Helper ---
have_cmd() { command -v "$1" >/dev/null 2>&1; }

strip_junk_ip() {
  # Hilangkan tanda kurung/braket/komma/titikdua di ujung
  local ip="$1"
  ip="${ip#[}" ; ip="${ip%]}"
  ip="${ip#(}" ; ip="${ip%)}"
  ip="${ip%,}" ; ip="${ip%:}"
  echo "$ip"
}

is_ip_like() {
  # Terima IPv4 atau IPv6 sederhana
  local ip="$1"
  [[ "$ip" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ || "$ip" =~ : ]]
}

# --- Load Limit IP & Expiry dari DB (jika ada) ---
if [ -r "$DB_FILE" ]; then
  while read -r line; do
      [[ "$line" =~ ^#ssh# ]] || continue
      user=$(echo "$line" | awk '{print $2}')
      limit=$(echo "$line" | awk '{print $3}')
      exp_date=$(echo "$line" | cut -d' ' -f4- | tr -d ',')
      [ -n "${user:-}" ] || continue

      LIMIT_IP["$user"]="${limit} IP"

      if [[ -n "$exp_date" ]]; then
          if exp_epoch=$(date -d "$exp_date" +%s 2>/dev/null); then
              now_epoch=$(date +%s)
              days=0
              if [[ $exp_epoch -ge $now_epoch ]]; then
                  days=$(( (exp_epoch - now_epoch) / 86400 ))
              fi
              DAYS_LEFT["$user"]="${days} days"
          else
              DAYS_LEFT["$user"]="N/A"
          fi
      else
          DAYS_LEFT["$user"]="N/A"
      fi
  done < "$DB_FILE"
fi

# --- Sumber baris autentikasi: journalctl ATAU file log ---
auth_stream() {
  # Prefer journalctl (systemd)
  if have_cmd journalctl; then
    # Jaring luas: ident + unit; 7 hari terakhir
    journalctl --no-pager -S -7days \
      -t sshd -t ssh -t dropbear \
      -u sshd -u ssh -u dropbear 2>/dev/null || true
    return
  fi
  # Fallback ke file log
  if [ -n "$LOG" ] && [ -e "$LOG" ]; then
    tail -n 100000 "$LOG"
    return
  fi
  return 0
}

# --- Kumpulkan login sukses dari LOG (riwayat terbaru) ---
collect_history() {
  local hits=0
  # Kita parse di AWK tanpa ketergantungan kolom tetap dan pid
  while read -r user ip; do
    [ -n "$user" ] && [ -n "$ip" ] || continue
    LOGIN_COUNT["$user"]+="$ip "
    hits=$((hits+1))
  done < <(
    auth_stream | awk '
      function emit(u, ip) {
        # Hapus tanda kurung/braket/koma/titikdua di pinggir
        gsub(/^[\[\(]/, "", ip); gsub(/[\]\),:]$/, "", ip);
        if (u != "" && ip != "") print u, ip;
      }

      # --- Dropbear ---
      /[Dd]ropbear.*Password auth succeeded/ {
        u=""; ip="";
        for (i=1; i<=NF; i++) {
          if ($i=="for")  { u=$(i+1); gsub(/\047/,"",u) } # strip petik tunggal
          if ($i=="from") { ip=$(i+1) }
        }
        emit(u, ip); next
      }

      # --- OpenSSH Accepted (cover invalid user, semua metode) ---
      /Accepted .* for / {
        u=""; ip="";
        for (i=1; i<=NF; i++) {
          if ($i=="for") {
            if ($(i+1)=="invalid" && $(i+2)=="user") { u=$(i+3) } else { u=$(i+1) }
          }
          if ($i=="from") { ip=$(i+1) }
        }
        emit(u, ip); next
      }
    '
  )

  # Fallback terakhir: gunakan wtmp (last -i) jika masih 0
  if [ "$hits" -eq 0 ] && have_cmd last; then
    while read -r u ip; do
      ip=$(strip_junk_ip "$ip")
      is_ip_like "$ip" || continue
      LOGIN_COUNT["$u"]+="$ip "
      hits=$((hits+1))
    done < <( last -i | awk 'NF>=3 && $1!="reboot" && $1!="shutdown" && $1!="wtmp" {print $1, $3}' )
  fi

  [ "$DEBUG" -eq 1 ] && echo "[DEBUG] history_hits=${hits}" >&2 || true
}

# --- Kumpulkan sesi yang SEDANG online sekarang ---
collect_live() {
  local hits=0

  if have_cmd who; then
    # who --ips -> kolom terakhir IP dalam tanda kurung
    while read -r u ip; do
      ip=$(strip_junk_ip "$ip")
      [ -n "$u" ] && is_ip_like "$ip" || continue
      ONLINE_IPS["$u"]+="$ip "
      hits=$((hits+1))
    done < <( who --ips 2>/dev/null | awk '{print $1, $NF}' )
    # Fallback kalau --ips tidak ada
    if [ "$hits" -eq 0 ]; then
      while read -r u ip; do
        ip=$(strip_junk_ip "$ip")
        [ -n "$u" ] && is_ip_like "$ip" || continue
        ONLINE_IPS["$u"]+="$ip "
        hits=$((hits+1))
      done < <( who 2>/dev/null | awk '{print $1, $NF}' )
    fi
  fi

  # Tambahan via ps: "sshd: user@pts/X" (tanpa IP tapi menandakan sesi aktif)
  if have_cmd ps; then
    while read -r u; do
      [ -n "$u" ] || continue
      # tambahkan placeholder agar terhitung minimal 1 sesi
      ONLINE_IPS["$u"]+=""
    done < <(
      ps -eo user,cmd --no-headers \
      | grep -E "sshd: .*@pts" \
      | grep -v grep \
      | awk '{print $1}' \
      | sort -u
    )
  fi

  [ "$DEBUG" -eq 1 ] && echo "[DEBUG] live_hits=${hits}" >&2 || true
}

# --- Jalankan kolektor sesuai MODE ---
if [ "$MODE" = "live" ]; then
  collect_live
else
  collect_history
fi

# --- Header ---
echo -e "\033[97;1m=====================================================\033[0m"
echo -e "\033[97;1m              SSH OPENVPN MONITOR ACCESS            \033[0m"
echo -e "\033[97;1m=====================================================\033[0m"
echo -e "\033[1;37m┌────────────┬──────────┬─────────────┬─────────────┐\033[0m"
printf "\033[97;1m│ %-10s │ %-8s │ %-11s │ %-11s │\033[0m\n" "LOGIN IP" "LIMIT" "USERNAME" "DAYS LEFT"
echo -e "\033[1;37m├────────────┼──────────┼─────────────┼─────────────┤\033[0m"

# --- Data ---
declare -A USERS_SEEN
for u in "${!LOGIN_COUNT[@]}"; do USERS_SEEN["$u"]=1; done
for u in "${!ONLINE_IPS[@]}";   do USERS_SEEN["$u"]=1; done

{
for user in "${!USERS_SEEN[@]}"; do
    if [ "$MODE" = "live" ]; then
      raw_ips="${ONLINE_IPS[$user]:-}"
    else
      raw_ips="${LOGIN_COUNT[$user]:-}"
    fi

    # Uniq IP (IPv4/IPv6); biarkan string kosong terhapus oleh sed
    readarray -t iplist < <(echo "$raw_ips" | tr ' ' '\n' | sed '/^$/d' | sort -u)
    login_ip_count=${#iplist[@]}

    # Jika live mode dan tidak dapat IP, hitung jumlah sesi sebagai fallback
    if [ "$MODE" = "live" ] && [ $login_ip_count -eq 0 ]; then
      sessions=$(echo "$raw_ips" | wc -w)
      [ $sessions -gt 0 ] && login_ip_count=$sessions
    fi

    limit_ip="${LIMIT_IP[$user]:-N/A}"
    days_left="${DAYS_LEFT[$user]:-N/A}"

    printf "\033[97;1m│ %-10s │ %-8s │ %-11s │ %-11s │\033[0m\n" \
        "${login_ip_count} IP" "$limit_ip" "$user" "$days_left"
done
} | sort -k3

# --- Footer ---
echo -e "\033[1;37m└────────────┴──────────┴─────────────┴─────────────┘\033[0m"

# Hitung “User Online/Detected”
COUNT_SHOW=0
for u in "${!USERS_SEEN[@]}"; do
  if [ "$MODE" = "live" ]; then
    [ -n "${ONLINE_IPS[$u]:-}" ] && COUNT_SHOW=$((COUNT_SHOW+1))
  else
    [ -n "${LOGIN_COUNT[$u]:-}" ] && COUNT_SHOW=$((COUNT_SHOW+1))
  fi
done

if [ "$MODE" = "live" ]; then
  echo -e "\033[1;32m${COUNT_SHOW} User Online\033[0m"
else
  echo -e "\033[1;32m${COUNT_SHOW} User Terdeteksi (riwayat terbaru)\033[0m"
fi

echo -e "\033[0;33m┌──────────────────────────────────────────┐\033[0m"
echo -e "      Autoscript By Arya Blitar       "
echo -e "\033[0;33m└──────────────────────────────────────────┘\033[0m"
echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu