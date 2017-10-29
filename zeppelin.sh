#script that installs zeppelin with all dependencies and starts it
ZEP_VER="0.7.3"

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
sudo apt-get install -y oracle-java8-installer wget
wget http://apache.javapipe.com/zeppelin/zeppelin-${ZEP_VER}/zeppelin-${ZEP_VER}-bin-all.tgz
tar -xzf zeppelin-${ZEP_VER}-bin-all.tgz
cd cd zeppelin-${ZEP_VER}-bin-all/
bin/zeppelin-daemon.sh start
	
