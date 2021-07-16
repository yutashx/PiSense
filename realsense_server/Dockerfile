FROM ubuntu:20.04

MAINTAINER yutashx

RUN apt-get clean
RUN apt-get update && apt-get upgrade -y

RUN apt-get install --no-install-recommends -y \
    make \
    neovim \
    python3.8 \
    python3-pip \
    python3-dev \
    libusb-1.0-0 \
    automake \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN ARCHFLAGS=-Wno-error=unused-command-line-argument-hard-error-in-future pip install -r /tmp/requirements.txt

WORKDIR /root

COPY librealsense2.so /usr/local/lib
COPY pyrealsense2.cpython-37m-arm-linux-gnueabihf.so /usr/lib/python3/dist-packages/pyrealsense2/

ARG UID=1000
RUN useradd -m -u ${UID} docker
USER ${UID}

CMD ["/bin/bash"]
