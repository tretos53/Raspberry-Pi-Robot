#!/bin/bash

:<<"USAGE"
$0 Filename robot.sh
$1 SSID
USAGE

if [ "$EUID" -ne 0 ]
        then echo "Must be root, run sudo -i before running this script."
        exit
fi

SSID=${1:-Robot}


echo "┌─────────────────────────────────────────"
echo "|This script might take a while,"
echo "|so if you dont see much progress,"
echo "|wait till you see --all done-- message."
echo "└─────────────────────────────────────────"
read -p "Press enter to continue"

echo "┌─────────────────────────────────────────"
echo "|Updating repositories"
echo "└─────────────────────────────────────────"
sudo apt-get update -yqq

# echo "┌─────────────────────────────────────────"
# echo "|Upgrading packages, this might take a while|"
# echo "└─────────────────────────────────────────"
# apt-get upgrade -yqq

echo "┌─────────────────────────────────────────"
echo "|Installing prerequisites"
echo "└─────────────────────────────────────────"
sudo apt-get install git -y
sudo apt-get install wiringpi -y

echo "┌─────────────────────────────────────────"
echo "|Installing and configuring nginx"
echo "└─────────────────────────────────────────"
apt-get install nginx -yqq
wget -q https://raw.githubusercontent.com/tretos53/Raspberry-Pi-Robot/master/default_nginx -O /etc/nginx/sites-enabled/default
wget -q https://raw.githubusercontent.com/tretos53/Raspberry-Pi-Robot/master/robot.php -O  /var/www/html/robot.php
mkdir /var/www/html/images/
wget -q https://github.com/tretos53/Raspberry-Pi-Robot/raw/master/images/forward.png -O  /var/www/html/images/forward.png
wget -q https://github.com/tretos53/Raspberry-Pi-Robot/raw/master/images/left.png -O  /var/www/html/images/left.png
wget -q https://github.com/tretos53/Raspberry-Pi-Robot/raw/master/images/reverse.png -O  /var/www/html/images/reverse.png
wget -q https://github.com/tretos53/Raspberry-Pi-Robot/raw/master/images/right.png -O  /var/www/html/images/right.png
wget -q https://github.com/tretos53/Raspberry-Pi-Robot/raw/master/images/stop.png -O  /var/www/html/images/stop.png

echo "┌─────────────────────────────────────────"
echo "|Installing dnsmasq"
echo "└─────────────────────────────────────────"
apt-get install dnsmasq -yqq

echo "┌─────────────────────────────────────────"
echo "|Configuring wlan0"
echo "└─────────────────────────────────────────"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dhcpcd.conf -O /etc/dhcpcd.conf

echo "┌─────────────────────────────────────────"
echo "|Configuring dnsmasq"
echo "└─────────────────────────────────────────"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/dnsmasq.conf -O /etc/dnsmasq.conf

echo "┌─────────────────────────────────────────"
echo "|configuring dnsmasq to start at boot"
echo "└─────────────────────────────────────────"
update-rc.d dnsmasq defaults

echo "┌─────────────────────────────────────────"
echo "|Installing hostapd"
echo "└─────────────────────────────────────────"
apt-get install hostapd -yqq

echo "┌─────────────────────────────────────────"
echo "|Configuring hostapd"
echo "└─────────────────────────────────────────"
wget -q https://raw.githubusercontent.com/tretos53/Captive-Portal/master/hostapd.conf -O /etc/hostapd/hostapd.conf
sed -i -- 's/#DAEMON_CONF=""/DAEMON_CONF="\/etc\/hostapd\/hostapd.conf"/g' /etc/default/hostapd
sed -i -- "s/CaptivePortal01/${SSID}/g" /etc/hostapd/hostapd.conf

echo "┌─────────────────────────────────────────"
echo "|Configuring iptables"
echo "└─────────────────────────────────────────"
iptables -t nat -A PREROUTING -s 192.168.24.0/24 -p tcp --dport 80 -j DNAT --to-destination 192.168.24.1:80
iptables -t nat -A POSTROUTING -j MASQUERADE
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt-get -y install iptables-persistent

echo "┌─────────────────────────────────────────"
echo "|configuring hostapd to start at boot"
echo "└─────────────────────────────────────────"
systemctl unmask hostapd.service
systemctl enable hostapd.service

echo "┌─────────────────────────────────────────"
echo "|Installing PHP7"
echo "└─────────────────────────────────────────"
apt-get install php7.3-fpm php7.3-mbstring php7.3-mysql php7.3-curl php7.3-gd php7.3-curl php7.3-zip php7.3-xml -yqq > /dev/null

echo "┌─────────────────────────────────────────"
echo "|Installing and configuring RPi-Cam-Web-Interface"
echo "└─────────────────────────────────────────"
sudo git clone https://github.com/silvanmelchior/RPi_Cam_Web_Interface.git
sudo wget -q https://raw.githubusercontent.com/tretos53/Raspberry-Pi-Robot/master/config.txt -O /home/pi/RPi_Cam_Web_Interface/config.txt
sudo chmod 664 /home/pi/RPi_Cam_Web_Interface/config.txt
sudo /home/pi/RPi_Cam_Web_Interface/install.sh q
sudo rm -f /etc/nginx/sites-enabled/*
sudo wget -q https://raw.githubusercontent.com/tretos53/Raspberry-Pi-Robot/master/default_nginx -O /etc/nginx/sites-enabled/default
sudo mv /var/www/html/index.php /var/www/html/index_rpicam.php
