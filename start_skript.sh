#!/bin/bash

PICAPPORT_PORT="$1"
PICAPPORT_LANG="$2"
XMS="$3"
XMX="$4"
CONFIG=".picapport/picapport.properties"
EXTRA_ARGS=""

# installs a minimal config if there is none present
[ ! -f "$CONFIG" ] && printf "%s\n%s\n%s\n" "server.port=$PICAPPORT_PORT" "robot.root.0.path=/opt/picapport/photos" "foto.jpg.usecache=2" > "$CONFIG"

# fix for filesystem monitor (v9.0.0 and up) not working in docker
if [ ! $(fgrep -i robot.use.filesystem.monitor $CONFIG) ]; then 
  echo "robot.use.filesystem.monitor=false" >> $CONFIG
fi

# default lang is german
[ -z "$PICAPPORT_LANG" ] && PICAPPORT_LANG="de"

# this tries to upgrade older data to the correct uid
[ $(find data/picapport.ks -uid 0 | wc -l ) -gt 0 ] && \
  echo "WARNING: to upgrade to this container version, you need change ownership of files: chown -R $UID data photos/uploads >/dev/null 2>&1" && \
  exit 0

function clean_up {
        echo "shutting down..."
        killall java
        wait %1
        echo "shutdown complete."
        exit
}

trap clean_up SIGHUP SIGINT SIGTERM

echo "starting picapport process..."

java -Duser.home=/opt/picapport -Duser.language="$PICAPPORT_LANG" -XX:MaxDirectMemorySize=3954m -Xms$XMS -Xmx$XMX -Dstorage.diskCache.bufferSize=512 $EXTRA_ARGS -jar picapport-headless.jar -configfile="$CONFIG" -pgui.enabled=false &

while true; do sleep 1; done    # wait for shutdown signals