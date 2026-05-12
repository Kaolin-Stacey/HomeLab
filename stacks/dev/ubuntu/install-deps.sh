#!/usr/bin/env bash
set -e

apt-get update
apt-get install -y \
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
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    python-is-python3 \
    openjdk-17-jdk

curl -O https://download.clojure.org/install/linux-install-1.11.1.1413.sh
chmod +x linux-install-1.11.1.1413.sh
./linux-install-1.11.1.1413.sh
rm linux-install-1.11.1.1413.sh

rm -rf /var/lib/apt/lists/*