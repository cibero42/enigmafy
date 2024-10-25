FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
        age \
        tar \
        rclone && \
    rm -rf /var/lib/apt/lists/*

COPY program/enigmafy.sh /usr/local/bin/enigmafy

RUN chmod +x /usr/local/bin/enigmafy

ENTRYPOINT ["/bin/bash"]
