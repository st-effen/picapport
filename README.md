# Picapport in a docker container
This docker image is based on [minideb](https://github.com/bitnami/minideb), a minimalistic debian image and has [picapport](https://www.picapport.de/de/index.php) installed. Also this image includes the PicApportVideoThumbnailPlugin, the PicApportJavaImagePlugin and the pagpMetadataAnalyser add-on.

## Supported architectures

This multiarch image supports `amd64`, `arm64v8`, `ppc64le`, and `s390x` on Linux.

## Starting the container
### For Windows & Linux
`docker run -d --name picapport -p 8080:80 ste3ff3n/picapport`

Thereafter you can access picapport on http://localhost:8080

## Specifying Custom Configurations

Create a file `picapport.properties` and save it in a folder, e.g. `config`. You can specify all parameter described in the [Picapport server guide](http://wiki.picapport.de/display/PIC/PicApport-Server+Guide):
```
server.port=80
robot.root.0.path=/srv/photos
foto.jpg.usecache=2
foto.jpg.cache.path=/srv/cache
```
In this file we specified, e.g., the path for picapport to search for the pictures inside the docker container, and the path, where all cached photos are stored.

## Easier setup with docker-compose
```YAML
version: '3'

services:
  picapport:
    image: steffen/picapport
    restart: always
    expose:
      - 80
    environment:
      - Xms=512m
      - Xmx=2g
      - PICAPPORT_LANG=de
    networks:
      - backend
    volumes:
      - /path/to/your/configuration:/opt/picapport/.picapport
      - /path/to/your/fotos:/srv/photos
```
Run it with `docker-compose up -d`
