#!/bin/bash
if [ $# -lt 1 ]
then
  echo "Need at least one param - user to add
  exit
fi

echo "enabling Password Login"
sudo sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

echo "reloading sshd"
sudo /etc/init.d/ssh reload

echo "adding user '$1'"
sudo adduser $1 --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password

if [ $# -gt 2 ]
then
	PASSWD=$2
else
  PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 10 | head -n 1)
fi
echo "setting user password to: $PASSWD"
echo "$1:$PASSWD" | sudo chpasswd

echo "adding user to sudo group"
sudo usermod -G adm,sudo,$1 $1
