## Adabot, Raspberry-Pi-Robot

Scripts to configure and operate this robot: https://www.hackster.io/tretos/learning-and-building-a-raspberry-pie-robot-290ac1

Above robot is based on https://www.explainingcomputers.com/rasp_pi_robotics.html

Tested on, without updating the system first, 2018-06-27-raspbian-stretch.zip

Flash microsd card with etcher

Put an empty file called ssh with no extension onto the boot partition, this will enable ssh at first boot. No need for screen and keyboard.

Connect to the SSH and run below command. You can get the IP address from IP scanner. If you run Raspberry Pi zero you need a screen and a keyboard to confugure wifi unless someone can help me with that.

Enable camera using command below and reboot.

```
sudo raspi-config
```

Run below
```
curl -H 'Cache-Control: no-cache' -sSL https://raw.githubusercontent.com/tretos53/Raspberry-Pi-Robot/master/adabot.sh | sudo bash $0
```
