#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

IMAGE=${1:-opencs18}
CMD_EXT=${@:2}
CMD=${CMD_EXT:-/bin/bash}

echo Running command $CMD with docker image $IMAGE

docker run -e HIST_FILE=/root/.bash_history -e FORCE_UNSAFE_CONFIGURE=1 -e BR2_EXTERNAL=/build --privileged --rm -v $DIR:/build -v ~/.docker_home:/root/ -it $IMAGE $CMD

echo finished