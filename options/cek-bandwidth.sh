#!/bin/bash

NC='\e[0m'
red='\e[1;31m'
green='\e[0;32m'
cyan='\x1b[96m'
white='\x1b[37m'
bold='\033[1m'
off='\033[0;37m'

clear
echo -e ""
echo -e "${cyan}======================================${off}"
echo -e        "           BANDWITH MONITOR "
echo -e "${cyan}======================================${off}"
echo -e "${green}"
echo -e "     1 ⸩   Lihat Total Bandwith Tersisa"

echo -e "     2 ⸩   Tabel Penggunaan Setiap 5 Menit"

echo -e "     3 ⸩   Tabel Penggunaan Setiap Jam"

echo -e "     4 ⸩   Tabel Penggunaan Setiap Hari"

echo -e "     5 ⸩   Tabel Penggunaan Setiap Bulan"

echo -e "     6 ⸩   Tabel Penggunaan Setiap Tahun"

echo -e "     7 ⸩   Tabel Penggunaan Tertinggi"

echo -e "     8 ⸩   Statistik Penggunaan Setiap Jam"

echo -e "     9 ⸩   Lihat Penggunaan Aktif Saat Ini"

echo -e "    10 ⸩   Lihat Trafik Penggunaan Aktif Saat Ini [5s]"

echo -e "     x ⸩   Menu"
echo -e "${off}"
echo -e "${cyan}======================================${off}"
echo -e "${green}"
read -p "     [#]  Masukkan Nomor :  " noo
echo -e "${off}"

case $noo in
1)
echo -e "${cyan}======================================${off}"
echo -e "    TOTAL BANDWITH SERVER TERSISA"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

2)
echo -e "${cyan}======================================${off}"
echo -e "  PENGGUNAAN BANDWITH SETIAP 5 MENIT"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -5

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

3)
echo -e "${cyan}======================================${off}"
echo -e "    PENGGUNAAN BANDWITH SETIAP JAM"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -h

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

4)
echo -e "${cyan}======================================${off}"
echo -e "   PENGGUNAAN BANDWITH SETIAP HARI"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -d

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

5)
echo -e "${cyan}======================================${off}"
echo -e "   PENGGUNAAN BANDWITH SETIAP BULAN"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -m

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2" 
;;

6)
echo -e "${cyan}======================================${off}"
echo -e "   PENGGUNAAN BANDWITH SETIAP TAHUN"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -y

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2" 
;;

7)
echo -e "${cyan}======================================${off}"
echo -e "    PENGGUNAAN BANDWITH TERTINGGI" 
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -t

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

8)
echo -e "${cyan}======================================${off}"
echo -e " GRAFIK BANDWITH TERPAKAI SETIAP JAM"
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -hg

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

9)
echo -e "${cyan}======================================${off}"
echo -e "  LIVE PENGGUNAAN BANDWITH SAAT INI"
echo -e "${cyan}======================================${off}"
echo -e " ${green}CTRL+C Untuk Berhenti!${off}"
echo -e ""

vnstat -l

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

10)
echo -e "${cyan}======================================${off}"
echo -e "   LIVE TRAFIK PENGGUNAAN BANDWITH "
echo -e "${cyan}======================================${off}"
echo -e ""

vnstat -tr

echo -e ""
echo -e "${cyan}======================================${off}"
echo -e "$baris2"
;;

x)
sleep 1
menu
;;

*)
sleep 1
echo -e "${red}Nomor Yang Anda Masukkan Salah!${off}"
;;
esac
read -n 1 -s -r -p "Press any key to back on menu info"

cek-bandwidth
