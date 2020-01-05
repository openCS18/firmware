#!/bin/bash

IMAGE=$1
CMD=${@:2}

echo Running command $CMD with docker image $IMAGE

docker run -e HIST_FILE=/root/.bash_history -e FORCE_UNSAFE_CONFIGURE=1 --privileged --rm -v `pwd`:/build -v ~/.docker_home:/root/ -it $IMAGE $CMD

echo finished