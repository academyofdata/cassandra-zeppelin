if [ $# -lt 1 ]
then
	echo "Please provide an argument to this script -> the name of the node to spin up"
	exit
fi

wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-cluster/master/gcloud-server-setup.sh | bash -s $1
zone=$(gcloud compute instances list --filter="name=$1" --format="value(zone)")
gcloud compute ssh $1 --zone $zone --command "wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-cluster/master/get-data.sh | sudo bash"
gcloud compute ssh $1 --zone $zone --command "wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-zeppelin/master/zeppelin.sh | sudo bash"

gcloud compute ssh $1 --zone $zone --command "wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-zeppelin/master/gcloud-user.sh | bash -s cuser"

gcloud compute --zone $zone firewall-rules create allow-zep --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8080 --source-ranges=0.0.0.0/0
