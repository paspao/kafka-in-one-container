FROM adoptopenjdk/openjdk11-openj9
LABEL maintainer="pasquale.paola@gmail.com" 
COPY start.sh /
RUN apt update && apt install -y supervisor && chmod a+x /start.sh
ADD kafka_2.12-2.3.0 kafka_2.12-2.3.0
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
EXPOSE 2181 9092
CMD ["/start.sh"]
