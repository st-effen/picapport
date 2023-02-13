# Picapport in a docker container
This docker image is based on [minideb](https://github.com/bitnami/minideb), a minimalistic debian image and has [picapport](https://www.picapport.de/de/index.php) installed. <!--Also this image includes the PicApportVideoThumbnailPlugin, the PicApportJavaImagePlugin and the pagpMetadataAnalyser add-on.-->

## Image in Docker Hub
Find the latest Image on [hub.docker.com](https://hub.docker.com/r/st3ff3n/picapport/)

docker pull st3ff3n/picapport:latest


## Supported architectures

This <!--multiarch--> image supports `amd64` <!--and `arm64v8`--> on Linux <!--and `amd64` on Windows-->.

## Starting the container
### For <!--Windows & -->Linux
`docker run -d --name picapport -p 8080:80 ste3ff3n/picapport`

Thereafter you can access picapport on http://localhost:8080

## Specifying Custom Configurations

Create a file `picapport.properties` and save it in a folder, e.g. `config`. You can specify all parameter described in the [Picapport server guide](http://wiki.picapport.de/display/PIC/PicApport-Server+Guide):
```
server.port=80
server.ssl=false
user.log.access=true
gui.enabled=false
robot.root.0.id=photos
robot.root.0.path=/srv/photos
```
In this file we specified, e.g., the path for picapport to search for the pictures inside the docker container, and the path, where all cached photos are stored.

## Easier setup with docker-compose
```YAML
version: '3'

services:
  picapport:
    image: st3ff3n/picapport:latest
    restart: always
    stop_grace_period: 5m # wait time to stop to prevent rebuild of db
    ports:
      - 80:80
    environment:
      - Xms=1g
      - Xmx=2g
      - LC_ALL=de_DE.UTF-8
      - PICAPPORT_LANG=de
    networks:
      - default
    volumes:
      - /path/to/your/configuration:/opt/picapport/.picapport
      - /path/to/your/photos:/srv/photos
```
Run it with `docker-compose up -d`

## Docker-compose for use with traefik as proxy

Enter your specific domain name in the labels section.

```YAML
version: '3'

services:
  picapport:
    image: st3ff3n/picapport:latest
    restart: always
    stop_grace_period: 5m # wait time to stop to prevent rebuild of db
    environment:
      - XMS=1g
      - XMX=2g
      - DTRACE=DEBUG
      - LC_ALL=de_DE.UTF-8
      - PICAPPORT_LANG=de

    networks:
      - default

    volumes:
      - /path/to/your/configuration:/opt/picapport/.picapport
      - /path/to/your/photos:/srv/photos

    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.picapport-1.entrypoints=http"
      - "traefik.http.routers.picapport-1.rule=Host(`example.com`)"  ## Enter the domain name ##
      - "traefik.http.middlewares.picapport-1-https-redirect.redirectscheme.scheme=https"
      - "traefik.http.routers.picapport-1.middlewares=picapport-1-https-redirect"
      - "traefik.http.routers.picapport-1-secure.entrypoints=https"
      - "traefik.http.routers.picapport-1-secure.rule=Host(`example.com`)" ## Enter the domain name ##
      - "traefik.http.routers.picapport-1-secure.tls=true"
      - "traefik.http.routers.picapport-1-secure.tls.certresolver=http"
      - "traefik.http.routers.picapport-1-secure.service=picapport-1"
      - "traefik.http.services.picapport-1.loadbalancer.server.port=80"
      - "traefik.docker.network=proxy"
```

Run it with `docker-compose up -d`
