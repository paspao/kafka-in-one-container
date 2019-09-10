Kafka in One container
======================

In many situations, I need an instance of Kafka for development purpose - if you develop services in a microservice architecture you know my problem! - but the lastest version of Kafka needs an instance of Zookeeper to start, this is very frustrating, you need a docker-compose only to make a test.

In most cases you don't need a cluster to test your work, so I have created a docker image containing Zookeeper and Kafka together, the container starts one instance of **supervisor** that manage the processes life.

I show you how step-by-step:

Download a stable version of Kafka from [https://kafka.apache.org/](https://kafka.apache.org/), then:

```docker
FROM adoptopenjdk/openjdk11-openj9
RUN apt update
RUN apt install -y supervisor
ADD kafka_2.12-2.3.0 kafka_2.12-2.3.0
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
```

* In the first line I choosed *adoptopenjdk* as base image because it is debian based (I want use *apt*) and it has a valid openjdk already installed
* An *apt update* it's needed to syncronyze the package manager repositories
* Then install supervisor and add a copy of Kafka as is and copy the following *supervisor.conf* file

```sh
[supervisord]
nodaemon=true

[program:zookeeper]
directory=/
user=root
command=/kafka_2.12-2.3.0/bin/zookeeper-server-start.sh /kafka_2.12-2.3.0/config/zookeeper.properties
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
startsecs=5

[program:kafka]
directory=/
user=root
command=/kafka_2.12-2.3.0/bin/kafka-server-start.sh /kafka_2.12-2.3.0/config/server.properties
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
starters=5

[program:topicOrderService]
user=root
directory=/
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
command=/kafka_2.12-2.3.0/bin/kafka-topics.sh --create --zookeper localhost:2181 --replication-factor 1 --partitions 1 --topic orderservice


[program:topicOrderHistoryService]
user=root
directory=/
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
command=/kafka_2.12-2.3.0/bin/kafka-topics.sh --create --zookeper localhost:2181 --replication-factor 1 --partitions 1 --topic orderhistoryservice

[program:topicKitchenService]
user=root
directory=/
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
command=/kafka_2.12-2.3.0/bin/kafka-topics.sh --create --zookeper localhost:2181 --replication-factor 1 --partitions 1 --topic kitchenservice

[program:topicDeliveryService]
user=root
directory=/
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
command=/kafka_2.12-2.3.0/bin/kafka-topics.sh --create --zookeper localhost:2181 --replication-factor 1 --partitions 1 --topic deliveryservice

```

Supervisor starts Zookeeper and it waits 5 seconds, then it starts Kafka broker. 
After 5 seconds it launchs 4 commands to generate some topic. That's all, the container is now running with a valid instance of Zookeeper and Kafka, you can bind the standard ports to interact with Kafka and Zookeeper.

Build
-----

```bash
docker build -t paspaola/kafka-mcpaspao:0.0.1 .
``

Run
---

```bash
docker run -it -p2181:2181 -p9092:9092 paspaola/kafka-mcpaspao:0.0.1
```

