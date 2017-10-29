#script that installs zeppelin with all dependencies and starts it
ZEP_VER="0.7.3"

PASSWORD='my-pass'

sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
echo "installing Oracle JDK"
sudo apt-get install -y oracle-java8-installer wget
echo "getting Zeppeling Archive"
wget http://apache.javapipe.com/zeppelin/zeppelin-${ZEP_VER}/zeppelin-${ZEP_VER}-bin-all.tgz
echo "unpacking..."
tar -xzvf zeppelin-${ZEP_VER}-bin-all.tgz
cd zeppelin-${ZEP_VER}-bin-all/
#enable authentication
cp conf/shiro.ini.template ./conf/shiro.ini
#the Apache shiro template comes with a bunch of users pre-defined, remove them
sed -i "/^user/d" ./conf/shiro.ini 
# admin default password in shiro.ini is password1, change it to a value of our own
sed -i "s/password1/${PASSWORD}/g" ./conf/shiro.ini

cp conf/zeppelin-site.xml.template conf/zeppelin-site.xml
#disable anonymous access
sed -i '/zeppelin.anonymous.allowed/{n;s/.*/<value>false<\/value>/}' ./conf/zeppelin-site.xml

echo "starting daemon..."
./bin/zeppelin-daemon.sh start


if [ $# -ge 1 ]
then
	echo "waiting for Zeppelin to start..."
	#wait untin Zeppelin starts and creates the interpreter.json file
	sleep 60
	sed -i "s/\"cassandra.hosts\": \"localhost\"/\"cassandra.hosts\": \"$1\"/g" ./conf/interpreter.json
	sed -i "s/\"cassandra.cluster\": \"Test Cluster\"/\"cassandra.cluster\": \"CassandraTraining\"/g" ./conf/interpreter.json
	sed -i "s/\"spark.cores.max\": \"\"/\"spark.cores.max\": \"\",\"spark.cassandra.connection.host\": \"$1\"/g" ./conf/interpreter.json
	echo "re-starting daemon..."
	./bin/zeppelin-daemon.sh restart

fi

	
