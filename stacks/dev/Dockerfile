FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    sudo \
    git \
    curl \
    wget \
    nano \
    vim \
    build-essential \
    gdb \
    valgrind \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir /var/run/sshd

ARG USERNAME=kaolin
ARG PASSWORD=kaolin

RUN useradd -m -s /bin/bash ${USERNAME} \
    && echo "${USERNAME}:${PASSWORD}" | chpasswd \
    && usermod -aG sudo ${USERNAME}

COPY sshd_config /etc/ssh/sshd_config

RUN mkdir -p /workspace \
    && chown -R ${USERNAME}:${USERNAME} /workspace

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]