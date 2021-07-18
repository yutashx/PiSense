FROM ubuntu:20.04

MAINTAINER yutashx

ENV DEBIAN_FRONTEND noninteractive
ENV TZ=Asia/Tokyo
ENV DISPLAY 1.0
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    make \
    neovim \
    python3.8 \
    python3-pip \
    libgl1 \
    libgomp1 \
    libusb-1.0-0 \
    libopencv-dev \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

ARG UID=1000
RUN useradd -m -u ${UID} docker
USER ${UID}

WORKDIR /root

CMD ["/bin/bash"]
