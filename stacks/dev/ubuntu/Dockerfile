FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

COPY install-deps.sh /tmp/install-deps.sh
RUN chmod +x /tmp/install-deps.sh && /tmp/install-deps.sh

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