#!/bin/bash
docker run -it --privileged --rm \
    -e DISPLAY=$DISPLAY \
    -v /dev/ati/card0:/dev/ati/card0:rw \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    "$@"
