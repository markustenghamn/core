#!/bin/bash
#
# ownCloud
#
# This script stops the docker container the files_external tests were run
# against. It will also revert the config changes done in setupDocker.sh
#
# @author Morris Jobke
# @copyright 2014 Morris Jobke hey@morrisjobke.de
#

if ! command -v docker >/dev/null 2>&1; then
    echo "No docker executable found - skipped docker stop"
    exit 0;
fi

echo "Docker executable found - stop and remove docker containers"

# retrieve current folder to remove the config from the parent folder
thisFolder=`echo $0 | replace "env/stopDocker.webdav.sh" ""`

## webdav

docker ps

# stopping and removing docker containers
for container in `docker ps | grep morrisjobke/webdav | cut -f 1 -d " "`; do
    echo "Stopping docker container $container"
    docker stop $container
    echo "Removing docker container $container"
    docker rm $container
done;

rm $thisFolder/config.webdav.php
