echo "enabling Password Login"
sudo sed -i -e 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config

echo "reloading sshd"
sudo /etc/init.d/ssh reload

echo "adding user '$1'"
sudo adduser $1 --gecos "First Last,RoomNumber,WorkPhone,HomePhone" --disabled-password

PASSWD=`openssl rand -base64 8`
echo "setting user password to: $PASSWD"
echo "$1:$PASSWD" | sudo chpasswd

echo "adding user to sudo group"
sudo usermod -G adm,sudo,$1 $1
