FROM ubuntu:20.04

# Set shell to bash instead of dash
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "dash dash/sh boolean false" | debconf-set-selections && dpkg-reconfigure dash

# Binwalk installation instructions from:
# https://github.com/ReFirmLabs/binwalk/blob/master/INSTALL.md
RUN apt-get update && apt-get install -y --no-install-recommends \
    arj \
    build-essential \
    bzip2 \
    cabextract \
    cramfsswap \
    # default-jdk \
    git-core \
    gzip \
    lhasa \
    liblzma-dev \
    liblzo2-dev \
    liblzo2-dev \
    lzop \
    mtd-utils \
    p7zip \
    p7zip-full \
    python3 \
    python3-lzo \
    python3-pip \
    python3-crypto \
    sleuthkit \
    squashfs-tools \
    srecord \
    tar \
    wget \
    zlib1g-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install binwalk from github
Run git clone https://github.com/ReFirmLabs/binwalk.git /tmp/binwalk && \
    cd /tmp/binwalk && \
    python3 setup.py install && \
    cd / && \
    rm -rf /tmp/binwalk

# Install sasquatch to extract non-standard SquashFS images
RUN git clone https://github.com/devttys0/sasquatch /tmp/sasquatch && \
    cd /tmp/sasquatch && \
    ./build.sh && \
    cd / && \
    rm -rf /tmp/sasquatch

# Install jefferson to extract JFFS2 file systems
RUN pip3 install cstruct && \
    git clone https://github.com/sviehb/jefferson /tmp/jefferson && \
    cd /tmp/jefferson && \
    python3 setup.py install && \
    cd / && \
    rm -rf /tmp/jefferson

# Install ubi_reader to extract UBIFS file systems
RUN git clone https://github.com/jrspruitt/ubi_reader /tmp/ubi_reader && \
    cd /tmp/ubi_reader && \
    python3 setup.py install && \
    cd / && \
    rm -rf /tmp/ubi_reader

# Install yaffshiv to extract YAFFS file systems
RUN git clone https://github.com/devttys0/yaffshiv /tmp/yaffshiv && \
    cd /tmp/yaffshiv && \
    python3 setup.py install && \
    cd / && \
    rm -rf /tmp/yaffshiv

# Install unstuff (closed source) to extract StuffIt archive files
RUN mkdir -p /tmp/unstuff && \
    cd /tmp/unstuff && \
    wget -O - http://mirror.sobukus.de/files/grimoire/z-archive/stuffit520.611linux-i386.tar.gz | tar -zxv && \
    install -m 0755 bin/unstuff /usr/local/bin/ && \
    rm -rf /tmp/unstuff

# Add ASA/PKG/CSP magic support
RUN git clone https://github.com/nezlooy/cisco-binwalk /tmp/cisco-binwalk && \
    cd /tmp/cisco-binwalk && \
    cp /tmp/cisco-binwalk/magic/* $(pip show binwalk | grep Location | awk -F ' '  '{print $2}')/binwalk/magic/ && \
    cp /tmp/cisco-binwalk/plugins/* $(pip show binwalk | grep Location | awk -F ' '  '{print $2}')/binwalk/plugins/

# Workspace volume from host
VOLUME [ "/iot" ]
WORKDIR /iot

# Call binwalk executable with arguments
ENTRYPOINT [ "binwalk", "--run-as=root" ]
CMD [ "-h" ]
