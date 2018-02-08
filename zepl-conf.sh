#!/bin/bash
apt-get install -y jq
file="/tmp/interpreter.json"
conf="conf/interpreter.json"
echo -e "{\n\"interpreterSettings\":{" > $file
jq -r '.interpreterSettings | .[] | select (.name == "spark") | .dependencies = [{"groupArtifactVersion": "com.datastax.spark:spark-cassandra-connector_2.11:2.0.6","local": false}] | "\""+.id +"\":" + (.|tostring)' $conf >> $file
echo "," >> $file
jq -r '.interpreterSettings | .[] | select (.name != "spark") | "\""+.id +"\":" + (.|tostring)' $conf |  paste -sd "," - >> $file
echo -e "},\n\"interpreterBindings\":" >> $file
jq -r '.interpreterBindings' $conf >> $file
echo -e ",\n\"interpreterRepositories\":" >> $file 
jq -r '.interpreterRepositories' $conf >> $file
echo "}" >> $file
