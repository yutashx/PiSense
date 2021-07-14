FROM nvidia/cuda:11.4.0-base-ubuntu20.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    make \
    neovim \
    python3.8 \
    python3-pip \
    libgl1 \
    libgomp1 \
    libusb-1.0-0 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

CMD ["/bin/bash"]
