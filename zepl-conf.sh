#!/bin/bash
#we'll use jq to tinker with the json file
sudo apt-get install -y jq
file="/tmp/interpreter.json"
conf="conf/interpreter.json"
#the default config json has three keys interpreterSettings, interpreterBindings and interpreterRepositories
echo -e "{\n\"interpreterSettings\":{" > $file
#find the spark interpreter and add cassandra artifact into dependencies
jq -r '.interpreterSettings | .[] | select (.name == "spark") | .dependencies = [{"groupArtifactVersion": "com.datastax.spark:spark-cassandra-connector_2.11:2.0.6","local": false}] | "\""+.id +"\":" + (.|tostring)' $conf >> $file
echo "," >> $file
#output the rest of (unmodified) interpreters
jq -r '.interpreterSettings | .[] | select (.name != "spark") | "\""+.id +"\":" + (.|tostring)' $conf |  paste -sd "," - >> $file
echo -e "},\n\"interpreterBindings\":" >> $file
#output verbatim the interpreterBindings and interpreterRepositories values
jq -r '.interpreterBindings' $conf >> $file
echo -e ",\n\"interpreterRepositories\":" >> $file 
jq -r '.interpreterRepositories' $conf >> $file
echo "}" >> $file
#make a backup of the original file
mv ${conf} ${conf}.bak
#move the modified file into place
mv ${file} ${conf}
#restart zeppelin
bin/zeppelin-daemon.sh restart
