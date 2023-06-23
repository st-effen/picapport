FROM bitnami/minideb:jessie

ARG ARCH=amd64

# Args from the build command only for build
ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION

# Environment variables for the container
ENV PICAPPORT_PORT 80
ENV PICAPPORT_LANG en
ENV PICAPPORT_LOG WARNING
ENV XMS 2048m
ENV XMX 4096m

# Install openjdk
RUN apt-get update && apt-get -y install openjdk-17-jre-headless locales locales-all

# Set the locale
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Make needed directories
RUN mkdir -p /opt/picapport && \
    mkdir /opt/picapport/.picapport && \
    mkdir /opt/picapport/.picapport/plugins && \
    mkdir /opt/picapport/.picapport/groovy

# Copy picapport files to container
COPY ./picapport-headless.jar /opt/picapport/picapport-headless.jar

# Copy start script to container
COPY ./start_skript.sh /opt/picapport/start_skript.sh

WORKDIR /opt/picapport

EXPOSE ${PICAPPORT_PORT}

ENTRYPOINT /opt/picapport/pa-start.sh $PICAPPORT_PORT $PICAPPORT_LANG $XMS $XMX

LABEL de.st3ff3n.picapport.version=$VERSION \
    de.st3ff3n.picapport.name="PicApport" \
    de.st3ff3n.picapport.docker.cmd="docker run -d -p 8080:80 st3ff3n/picapport" \
    de.st3ff3n.picapport.vendor="Steffen Issler" \
    de.st3ff3n.picapport.architecture=$ARCH \
    de.st3ff3n.picapport.vcs-ref=$VCS_REF \
    de.st3ff3n.picapport.vcs-url=$VCS_URL \
    de.st3ff3n.picapport.build-date=$BUILD_DATE
