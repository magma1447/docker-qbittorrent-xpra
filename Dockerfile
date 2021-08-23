FROM ghcr.io/linuxserver/baseimage-ubuntu:focal
MAINTAINER Magnus Månsson "magma@1447.se"

# set version label
ARG QBITTORRENT_VERSION

# environment settings
ARG DEBIAN_FRONTEND="noninteractive"
ENV HOME="/config" \
XDG_CONFIG_HOME="/config" \
XDG_DATA_HOME="/config"

RUN \
  echo "***** add xpra repository ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg \
    gpgv \
    curl && \
  curl -s https://xpra.org/gpg.asc | apt-key add - && \
  echo "deb https://xpra.org/ focal main" >> /etc/apt/sources.list.d/xpra.list && \
  echo "**** install xpra packages ****" && \
  apt-get update && \
  apt-get install -y \
    xpra && \
  echo "**** install chrome ****" && \
  curl -LO https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
  apt-get install -y ./google-chrome-stable_current_amd64.deb && \
  rm google-chrome-stable_current_amd64.deb && \
  echo "***** add qbitorrent repositories ****" && \
  apt-get update && \
  apt-get install -y \
    gnupg \
    python3 && \
  curl -s https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/gpg.F8756541ADDA2B7D.key | apt-key add - && \
  apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 7CA69FC4 && \
  echo "deb http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb-src http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/deb/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "deb-src https://dl.cloudsmith.io/public/qbittorrent-cli/qbittorrent-cli/deb/ubuntu focal main" >> /etc/apt/sources.list.d/qbitorrent.list && \
  echo "**** install qbittorrent packages ****" && \
  if [ -z ${QBITTORRENT_VERSION+x} ]; then \
    QBITTORRENT_VERSION=$(curl -sX GET http://ppa.launchpad.net/qbittorrent-team/qbittorrent-stable/ubuntu/dists/focal/main/binary-amd64/Packages.gz | gunzip -c \
    |grep -A 7 -m 1 "Package: qbittorrent" | awk -F ": " '/Version/{print $2;exit}');\
  fi && \
  apt-get update && \
  apt-get install -y \
    p7zip-full \
    qbittorrent-cli \
    qbittorrent=${QBITTORRENT_VERSION} \
    unrar \
    geoip-bin \
    unzip && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 6881 6881/udp 8080
VOLUME /config

