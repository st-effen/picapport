ARG IMAGE=alpine:latest

# first image to download qemu and make it executable
FROM alpine AS qemu
ARG QEMU=x86_64
ARG QEMU_VERSION=4.2.0-6
ADD https://github.com/multiarch/qemu-user-static/releases/download/v${QEMU_VERSION}/qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
RUN chmod -x /usr/bin/qemu-${QEMU}-static

# second image to deliver the picapport container
FROM ${IMAGE}
ARG QEMU=x86_64
COPY --from=qemu /usr/bin/qemu-${QEMU}-static /usr/bin/qemu-${QEMU}-static
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
RUN apt-get update && apt-get -y install openjdk-11-jre-headless locales

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

WORKDIR /opt/picapport

EXPOSE ${PICAPPORT_PORT}

#ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar

CMD exec java -Xms$XMS -Xmx$XMX -Djava.awt.headless=true -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar

LABEL de.st3ff3n.picapport.version=$VERSION \
    de.st3ff3n.picapport.name="PicApport" \
    de.st3ff3n.picapport.docker.cmd="docker run -d -p 8080:80 st3ff3n/picapport" \
    de.st3ff3n.picapport.vendor="Steffen Issler" \
    de.st3ff3n.picapport.architecture=$ARCH \
    de.st3ff3n.picapport.vcs-ref=$VCS_REF \
    de.st3ff3n.picapport.vcs-url=$VCS_URL \
    de.st3ff3n.picapport.build-date=$BUILD_DATE
