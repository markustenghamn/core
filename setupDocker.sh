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


## webdav

# docker parameters
# -d run in background
# -P map internal ports to a unused high port on the host (between 49153 and 65535)
# -e set env variables
container=`docker run -d -P -e USERNAME=test -e PASSWORD=test morrisjobke/webdav`

# get mapped port on host for internal port 80 - output is IP:PORT - we need to extract the port with 'cut'
port=`docker port $container 80 | cut -f 2 -d :`

# This sed command will change the webdav config
#
#   1 and 2 limits the replacement part
#     1 is the start expression
#     2 is the end expression
#     => replace between: 'webdav'O=>array( and ),
#
#   3 and 4 is the actual replacement of
#     3 the expression to catch the current value
#     4 what should there be inserted
#     => replace: run.* by run'=>true,
#
#           This restricts sed  |
#          command to following |      with
#                 part:         |
#             (webdav config)   |
#          BEGIN           END  |BEFORE    AFTER
#        111111111111111   22    33333 44444444444
sed -i "/'webdav'=>array/,/),/ s/run.*/run'=>true,/"                         apps/files_external/tests/config.php
sed -i "/'webdav'=>array/,/),/ s/host.*/host'=>'localhost:$port\/webdav',/"   apps/files_external/tests/config.php
