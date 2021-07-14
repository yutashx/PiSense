FROM nvidia/cuda:11.4.0-base-ubuntu20.04

RUN apt-get update && apt-get upgrade -y
RUN apt-get install --no-install-recommends -y \
    neovim \
    python3.8 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

CMD ["/bin/bash"]
