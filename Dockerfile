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
ENV XMS 1024m
ENV XMX 4096m

# Install openjdk
#RUN apt-get update && apt-get upgrade -y && apt-get -y install openjdk-11-jre-headless
RUN apt-get update && apt-get -y install openjdk-11-jre

# Make needed directories
RUN mkdir -p /opt/picapport && \
    mkdir /opt/picapport/.picapport && \
    mkdir /opt/picapport/.picapport/plugins && \
    mkdir /opt/picapport/.picapport/groovy

# Copy picapport files to container
COPY ./picapport-headless.jar /opt/picapport/picapport-headless.jar
COPY ./PicApportVideoThumbnailPlugin.zip /opt/picapport/.picapport/plugins/PicApportVideoThumbnailPlugin.zip
COPY ./PicApportJavaImagePlugin.zip /opt/picapport/.picapport/plugins/PicApportJavaImagePlugin.zip
COPY ./apache-groovy-binary-3.0.9.zip /opt/picapport/.picapport/groovy/apache-groovy-binary-3.0.9.zip
COPY ./pagpMetadataAnalyser-1.1.0.zip /opt/picapport/.picapport/groovy/pagpMetadataAnalyser-1.1.0.zip

# Copy default config file
COPY ./config/picapport.properties /opt/picapport/.picapport/picapport.properties

WORKDIR /opt/picapport

EXPOSE ${PICAPPORT_PORT}

ENTRYPOINT java -Xms$XMS -Xmx$XMX -DTRACE=$PICAPPORT_LOG -Duser.language=$PICAPPORT_LANG -Duser.home=/opt/picapport -jar picapport-headless.jar

LABEL de.st3ff3n.picapport.version=$VERSION \
    de.st3ff3n.picapport.name="PicApport" \
    de.st3ff3n.picapport.docker.cmd="docker run -d -p 8080:80 st3ff3n/picapport" \
    de.st3ff3n.picapport.vendor="Steffen Issler" \
    de.st3ff3n.picapport.architecture=$ARCH \
    de.st3ff3n.picapport.vcs-ref=$VCS_REF \
    de.st3ff3n.picapport.vcs-url=$VCS_URL \
    de.st3ff3n.picapport.build-date=$BUILD_DATE
