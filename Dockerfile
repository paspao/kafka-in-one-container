FROM adoptopenjdk/openjdk11-openj9
#ENV HTTP_PROXY 
#ENV HTTPS_PROXY 
RUN apt update
RUN apt install -y supervisor
ADD kafka_2.12-2.3.0 kafka_2.12-2.3.0
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
CMD ["/usr/bin/supervisord","-c","/etc/supervisor/conf.d/supervisord.conf"]
