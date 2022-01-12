FROM bitnami/minideb:jessie

ENV PICAPPORT_PORT 80
ENV PICAPPORT_LANG en
ENV PICAPPORT_LOG WARNING
ENV XMS 256m
ENV XMX 1024m


RUN apt-get update && apt-get upgrade -y && apt-get -y install openjdk-11-jre && \

    mkdir -p /opt/picapport && \
    mkdir /opt/picapport/.picapport

WORKDIR /opt/picapport
COPY picapport-headless.jar picapport-headless.jar

EXPOSE ${PICAPPORT_PORT}


ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar
