#script that installs zeppelin with all dependencies and starts it
ZEP_VER="0.7.3"

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo "installing Oracle JDK"
sudo apt-get install -y oracle-java8-installer wget
echo "getting Zeppeling Archive"
wget http://apache.javapipe.com/zeppelin/zeppelin-${ZEP_VER}/zeppelin-${ZEP_VER}-bin-all.tgz
echo "unarchiving..."
tar -xzf zeppelin-${ZEP_VER}-bin-all.tgz
cd zeppelin-${ZEP_VER}-bin-all/
echo "starting daemon..."
bin/zeppelin-daemon.sh start
	
