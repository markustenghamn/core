#!/bin/bash
#
# ownCloud
#
# This script start a docker container to test the files_external tests
# against. It will also change the files_external config to use the docker
# container as testing environment. This is reverted in stopDocker.sh
#
# @author Morris Jobke
# @copyright 2014 Morris Jobke hey@morrisjobke.de
#

if ! command -v docker >/dev/null 2>&1; then
    echo "No docker executable found - skipped docker setup"
    exit 0;
fi

echo "Docker executable found - setup docker"

# retrieve current folder to place the config in the parent folder
thisFolder=`echo $0 | replace "env/startDocker.webdav.sh" ""`

## webdav

# docker parameters
# -d run in background
# -P map internal ports to a unused high port on the host (between 49153 and 65535)
# -e set env variables
container=`docker run -d -P -e USERNAME=test -e PASSWORD=test morrisjobke/webdav`

# get mapped port on host for internal port 80 - output is IP:PORT - we need to extract the port with 'cut'
port=`docker port $container 80 | cut -f 2 -d :`


cat > $thisFolder/config.webdav.php <<DELIM
<?php

return array(
    'run'=>true,
    'host'=>'localhost:$port/webdav',
    'user'=>'test',
    'password'=>'test',
    'root'=>'',
    // wait delay in seconds after write operations
    // (only in tests)
    // set to higher value for lighttpd webdav
    'wait'=> 0
);

DELIM
