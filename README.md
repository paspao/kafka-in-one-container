Kafka in One container
======================
[![Build Status](https://travis-ci.org/paspao/kafka-in-one-container.svg?branch=master)](https://travis-ci.org/paspao/kafka-in-one-container)

In many situations, I need an instance of Kafka for development purpose - if you develop services in a microservice architecture you know my problem! - but the lastest versions of Kafka need an instance of Zookeeper to start, this is very frustrating, you need a docker-compose only to make a test.

In most cases you don't need a cluster to test your work but only a single broker, so I have created a docker image containing Zookeeper and Kafka (version 2.12-2.3.0) together, the container starts one instance of **supervisor** that manage the processes life.

I show you how step-by-step:

Download a stable version of Kafka from [https://kafka.apache.org/](https://kafka.apache.org/), then:

```docker
FROM adoptopenjdk/openjdk11-openj9
LABEL maintainer="pasquale.paola@gmail.com" 
COPY start.sh /
RUN apt update && apt install -y supervisor && chmod a+x /start.sh
ADD kafka_2.12-2.3.0 kafka_2.12-2.3.0
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 2181 9092
CMD ["/start.sh"]
```

* In the first line I choosed *adoptopenjdk* as base image because it is debian based (I want use *apt*) and it has a valid openjdk already installed
* COPY the *start.sh* file in the root (details below)
* An *apt update* it's needed to syncronyze the package manager repositories
* Then install supervisor and add a copy of Kafka as is and copy the following *supervisor.conf* file

The *start.sh* manage the environment variable *KAFKA_ADVERTISED_LISTNERS* used to configure the Kafka advertise url.

```bash
#!/bin/bash -e

if [[ -z "$KAFKA_ADVERTISED_LISTNERS" ]]; then
    echo "ERROR: missing mandatory config: KAFKA_ADVERTISED_LISTNERS"
    exit 1
fi

echo "advertised.listeners=PLAINTEXT://$KAFKA_ADVERTISED_LISTNERS:9092" >> /kafka_2.12-2.3.0/config/server.properties

exec "/usr/bin/supervisord" "-c" "/etc/supervisor/conf.d/supervisord.conf"
```

At the end of *start.sh*, it starts the *supervisor daemon* with the following configuration:

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

[program:kafka]
directory=/
user=root
command=/kafka_2.12-2.3.0/bin/kafka-server-start.sh /kafka_2.12-2.3.0/config/server.properties
stdout_logfile=/dev/fd/1
stdout_logfile_maxbytes=0
redirect_stderr=true
starters=5

```

Supervisor starts Zookeeper and one Kafka broker: that's all. 
The container is now running with a valid instance of Zookeeper and Kafka, you can bind the standard ports to interact with Kafka and Zookeeper.

Build
-----

```bash
docker build -t paspaola/kafka-one-container:0.0.1 .
```

Run
---

```bash
docker run -it -p2181:2181 -p9092:9092 -e "KAFKA_ADVERTISED_LISTNERS={your-host-address}" paspaola/kafka-one-container:0.0.1
```

