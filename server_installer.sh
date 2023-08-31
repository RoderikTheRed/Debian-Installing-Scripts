#!/bin/bash

RED="\e[31m"
GREEN="\e[92m"
DEFAULT="\e[35m"
ENDCOLOR="\e[0m"

echo -e "${DEFAULT}Apache2 & MySQL(PhpMyAdmin) Installer by RoderikTheRed${ENDCOLOR}"
echo -e "${DEFAULT}INFO: Checking Privileges...${ENDCOLOR}"
if [ "$EUID" -ne 0 ]
	then echo -e "${RED}FAILED: This script requires Sudo/Root Privileges to run properly!${ENDCOLOR}"
	exit
fi
echo -e "${DEFAULT}INFO: Updating System...${ENDCOLOR}"
apt -qqy update
echo "${DEFAULT}INFO: Starting Downloading...${ENDCOLOR}"
apt -qqy install apache2 mariadb-server php php-xml php-mysqli php-curl php-mysql php-mbstring3 unzip wget
echo ""
echo -e "${GREEN}SUCCESS: Finished Downloading, setting up...${ENDCOLOR}"
echo ""
echo -e "${DEFAULT}INFO: Setting Up MySQL Database...\n Please Enter your Options!${ENDCOLOR}"
mysql_secure_installation
echo -e "${GREEN}SUCCESS: Finished Setting Up MySQL Database...${ENDCOLOR}"
echo ""
echo -e "${DEFAULT}INFO: Setting up PhpMyAdmin...${ENDCOLOR}"
wget -O /usr/share/phpmyadmin.zip https://files.phpmyadmin.net/phpMyAdmin/5.1.1/phpMyAdmin-5.1.1-all-languages.zip
unzip /usr/share/phpmyadmin.zip
rm /usr/share/phpmyadmin.zip
mv /usr/share/phpMyAdmin-*-all-languages /usr/share/phpmyadmin
chmod -R 0755 /usr/share/phpmyadmin
wget -O /etc/apache2/conf-available/phpmyadmin.conf https://pastebin.com/raw/VFAuWSyq
a2enconf phpmyadmin
systemctl reload apache2
mkdir /usr/share/phpmyadmin/tmp
chown -R www-data:www-data /usr/share/phpmyadmin/tmp/
mysql --user="root" -p --execute="UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND plugin = 'unix_socket';"
echo ""
echo -e "${GREEN}SUCCESS: Finished Setting Up Everything${ENDCOLOR}"
echo ""
adapter=$(ip link | awk -F: '$0 !~ "lo|vir|wl|docker|^[^0-9]"{print $2;getline}')
ip4=$(/sbin/ip -o -4 addr list $adapter | awk '{print $4}' | cut -d/ -f1)
echo -e "${DEFAULT}Website is accessable at: http://$ip4/${ENDCOLOR}"
echo -e "${DEFAULT}PhpMyAdmin is accessable at: http://$ip4/phpmyadmin${ENDCOLOR}"
