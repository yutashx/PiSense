FROM ubuntu:20.04

MAINTAINER yutashx

RUN apt-get clean
RUN apt-get update && apt-get upgrade -y

RUN apt-get install --no-install-recommends -y \
    make \
    neovim \
    python3.8 \
    python3-pip \
    libusb-1.0-0 \
    python3-dev \
    libusb-1.0-0 \
    automake \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

WORKDIR /root

ARG UID=1000
RUN useradd -m -u ${UID} docker
USER ${UID}

WORKDIR /root

CMD ["/bin/bash"]
