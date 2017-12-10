#!/bin/bash
#replace zone as needed
ZONE="europe-west1-d"
SID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 6 | tr '[:upper:]' '[:lower:]'| head -n 1)
INSTANCE="zep-${SID}"

gcloud compute instances create ${INSTANCE} --tags zeppelin --zone ${ZONE} --machine-type n1-standard-1 --maintenance-policy "MIGRATE" --image "https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts" --boot-disk-size "10" --boot-disk-type "pd-standard" --boot-disk-device-name "${INSTANCE}disk"

echo "waiting for the machine to come up"
sleep 25

CASSANDRA=$(gcloud compute instances list --filter="labels.cassandra-seed=true" --format="value(networkInterfaces[0].networkIP)")

echo "installing Apache Zeppelin on remote node"
gcloud compute ssh ${INSTANCE} --zone $ZONE --command "wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-zeppelin/master/zeppelin.sh | bash -s $CASSANDRA"

gcloud compute firewall-rules create allow-zep --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:8080 --source-ranges=0.0.0.0/0

EXTIP=$(gcloud compute instances list --filter="name=${INSTANCE}" --format="value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "Access Zeppelin interface at http://${EXTIP}:8080"

