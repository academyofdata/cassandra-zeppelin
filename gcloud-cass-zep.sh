
safeRun() {
  typeset cmnd="$*"
  typeset ret_code

  echo cmnd=$cmnd
  eval $cmnd
  ret_code=$?
  if [ $ret_code != 0 ]; then
    printf "Error : [%d] when executing command: '$cmnd'" $ret_code
    exit $ret_code
  fi
}

if [ $# -lt 1 ]
then
	echo "Please provide an argument to this script -> the name of the node to spin up"
	exit
fi
echo "Creating a Google Cloud Engine VM instance"
wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-cluster/master/gcloud-server-setup.sh | bash -s $1
zone=$(gcloud compute instances list --filter="name=$1" --format="value(zone)")
echo "Instance is created in the zone $zone"
echo "Downloading sample data ..."
safeRun "gcloud compute ssh $1 --zone $zone --command \"wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-cluster/master/get-data.sh | bash\""
echo "Downloading and setting up Apache Zeppelin ..."
safeRun "gcloud compute ssh $1 --zone $zone --command \"wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-zeppelin/master/zeppelin.sh | bash\""
echo "Adding the user 'cuser' for ssh login"
safeRun "gcloud compute ssh $1 --zone $zone --command \"wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-zeppelin/master/gcloud-user.sh | bash -s cuser\""
echo "Creating a firewall rule to allow Zeppelin access"
safeRun "gcloud compute --zone $zone firewall-rules create allow-zep --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8080 --source-ranges=0.0.0.0/0"
