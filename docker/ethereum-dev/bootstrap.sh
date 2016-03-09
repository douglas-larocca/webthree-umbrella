#!/bin/bash

NPROC=$(nproc)

case $NPROC in
    [1-3]) USE_PROC=1 ;;
    [4-6]) USE_PROC=2 ;;
    [7-8]) USE_PROC=6 ;;
    *) USE_PROC=8 ;;
esac

[ $USE_PROC -gt $NPROC ] && {
    echo 'nproc' >&2
    exit 1
}

UID="$(id -u)"
GID="$(id -g)"

# GFX_DRIVER=fglrx for ATI/Radeon cards
GFX_DRIVER=fglrx

>Dockerfile cat - <<EOF
FROM ubuntu:14.04
MAINTAINER Douglas La Rocca <larocca@larocca.io>

ENV DEBIAN_FRONTEND noninteractive

RUN sed 's/main$/main universe/' -i /etc/apt/sources.list && \\
    apt-get update && apt-get upgrade -y && \\
    apt-get install -y software-properties-common && \\
    apt-get update && apt-get -y upgrade && \\
    apt-get install -y -q wget && \\
    wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - && \\
    apt-add-repository ppa:george-edison55/cmake-3.x && \\
    add-apt-repository "deb http://llvm.org/apt/trusty/ llvm-toolchain-trusty-3.7 main" && \\
    add-apt-repository ppa:ethereum/ethereum-qt && \\
    add-apt-repository ppa:ethereum/ethereum && \\
    add-apt-repository ppa:ethereum/ethereum-dev && \\
    apt-get -y update && \\
    apt-get -y upgrade && \\
    apt-get -y install \\
        build-essential \\
        $GFX_DRIVER \\
        cmake \\
        git \\
        libargtable2-dev \\
        libboost-all-dev \\
        libcryptopp-dev \\
        libcurl4-openssl-dev \\
        libedit-dev \\
        libgoogle-perftools-dev \\
        libgmp-dev \\
        libjson-rpc-cpp-dev \\
        libjsoncpp-dev \\
        libleveldb-dev \\
        libmicrohttpd-dev \\
        libminiupnpc-dev \\
        libncurses5-dev \\
        libqt5webkit5-dev \\
        libqt5webengine5-dev \\
        libqt5qml-graphicaleffects \\
        libreadline-dev \\
        libv8-dev \\
        libz-dev \\
        llvm-3.7-dev \\
        mesa-common-dev \\
        ocl-icd-libopencl1 \\
        opencl-headers \\
        ocl-icd-dev \\
        qml-module-qtquick-controls \\
        qml-module-qtquick-dialogs \\
        qml-module-qtquick-layouts \\
        qml-module-qtwebkit \\
        qml-module-qt-labs-settings \\
        qml-module-qtwebengine \\
        qml-module-qtquick2 \\
        qml-module-qtquick-privatewidgets \\
        qtbase5-dev \\
        qt5-default \\
        qtdeclarative5-dev \\
        --no-install-recommends

RUN mkdir -p /home/${USER} && \\
    echo "${USER}:x:${UID}:${UID}:${USER},,,:/home/${USER}:/bin/bash" >> /etc/passwd && \\
    echo "${USER}:x:${GID}:" >> /etc/group && \\
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${USER} && \\
    chmod 0440 /etc/sudoers.d/${USER} && \\
    chown ${USER}:${USER} -R /home/${USER}

USER $USER
ENV HOME /home/$USER
WORKDIR /home/$USER

RUN git clone --recursive https://github.com/ethereum/webthree-umbrella && \\
    cd webthree-umbrella && \\
    git checkout release && \\
    git submodule update && \\
    mkdir build && \\
    cd build && \\
    cmake .. && \\
    make -j $USE_PROC

CMD [ "/bin/bash" ]
EOF
