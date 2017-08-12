# Cassandra + Spark + Zeppelin

This is a repository for a docker-compose script that creates two Docker containers - one with a Zeppelin instance and the other one with a Cassandra node

## Configuration and Installation
Make sure to have a valid Docker and docker-compose Installation, running on a 64-bit system (either directly on a mac or Linux machine, or on a VirtualBox - or similar - VM running a 64-bit guest; this means that you'll end up running Docker inside a VM, this is fine for testing and learning purposes). 

To install/configure Docker and/or Docker Compose follow the steps described at https://docs.docker.com/compose/install/ and https://docs.docker.com/engine/installation/linux/ubuntu/ (this is for Ubuntu based Linux systems)

## Usage
Once the docker & docker-compose prerequisites are met, go on and clone this repository 
e.g. 
```
git clone https://github.com/academyofdata/cassandra-zeppelin
```
followed by
```
cd cassandra-zeppelin
docker-compose build
docker-compose up -d
```
Assuming that you haven't encountered problems during build or run phase, you can now test that the containers are running by issuing the following command
```
docker ps
```
which should have an output similar with the one below
```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                                                                                      NAMES
110e8f4b16b3        zeppelin_zeppelin   "bin/zeppelin.sh"        4 days ago          Up 3 days           0.0.0.0:4040->4040/tcp, 0.0.0.0:8080-8081->8080-8081/tcp                                                   zeppelin_zeppelin_1
bbb70c263987        cassandra:3.9       "/docker-entrypoint.s"   4 days ago          Up 3 days           0.0.0.0:7000-7001->7000-7001/tcp, 0.0.0.0:7199->7199/tcp, 0.0.0.0:9042->9042/tcp, 0.0.0.0:9160->9160/tcp   zeppelin_cassandra_1
```
(pay attention in special to the STATUS column - it should say Up and not Exited)
Once the containers are running you can go to http://virtualmachineip:8080 (replace with your own VirtualBox or local machine IP) and you should see the Zeppelin interface

# Bulk-Loading data in Cassandra
To load all the exercise data into a newly created "test" keyspace and creating all the required tables, run the following command inside the Cassandra container (if you have an existing "test" keyspace, drop it)

```
apt-get update && apt-get install -y wget && wget -qO- https://raw.githubusercontent.com/academyofdata/cassandra-zeppelin/master/script.sh | bash
```
(to log into the container run 'docker exec -ti containers_cassandra_1 bash' from your container host, after you check the exact name of your container with 'docker ps -a')

# Starting a Zeppelin instance connected to a Cassandra cluster (with 3 nodes)
***PLEASE NOTE***
If you've previously started other containers with Zeppelin (for instance the Zeppelin + a single Cassandra node as outlined above), make sure to stop them before starting the instance connected to the cluster. You can do that with
```
docker-compose stop
```

Otherwise there will be port conflicts when attempting to start the new cluster and the new Zeppelin instance. 

Start with this more complex configuration by issuing the command below (in the same folder where you've cloned this git repository)

```
docker-compose -f docker-cluster.yml up -d
```

After starting check that the containers are running (``` docker ps -a ```), wait for a few seconds (20-30 should be enough), log into one of the cassandra nodes (``` docker exec -ti zeppelin_node01_1 bash ```) and check the cluster status (run this in the container)
```
nodetool status
```
If the cluster started correctly you should see back a few lines, three of them starting with UN, like this
```
Datacenter: datacenter1
=======================
Status=Up/Down
|/ State=Normal/Leaving/Joining/Moving
--  Address     Load       Tokens       Owns (effective)  Host ID                               Rack
UN  172.17.0.3  110.13 KiB  256          67.6%             5460abe0-cf14-4d87-bf11-04f4ccd3f14c  rack1
UN  172.17.0.2  108.46 KiB  256          62.0%             17d1e7cd-2ff6-4397-8495-a42c12a3807f  rack1
UN  172.17.0.4  103.09 KiB  256          70.4%             70d2d32c-d7cd-4662-9e98-906167b0e4b7  rack1
```
This means that all the nodes are up (U) and operating normally (N)


# Starting a Zeppelin only instance

Edit the docker-compose.yml file to read as below
```
zeppelin:
  image:  dylanmei/zeppelin
  environment:
    ZEPPELIN_PORT: 8080
    ZEPPELIN_JAVA_OPTS: >-
      -Dspark.driver.memory=1g
      -Dspark.executor.memory=2g
    SPARK_SUBMIT_OPTIONS: >-
      --conf spark.driver.host=localhost
      --conf spark.driver.port=8081
      
    MASTER: local[*]
  ports:
    - 8080:8080
    - 8081:8081
    - 4040:4040
  volumes:
    - ./znotebooks:/usr/zeppelin/notebook
```
and issue the same docker-compose up -d command
