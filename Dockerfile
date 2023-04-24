FROM ghcr.dockerproxy.com/linuxserver/baseimage-ubuntu:jammy

# set version label
ARG BUILD_DATE
ARG VERSION
ARG CALIBREWEB_RELEASE=Develop
ARG CALIBRE_RELEASE=6.16.0
ARG KEPUBIFY_RELEASE=4.0.4
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"
RUN \
  echo "**** apt-get换国内源" && \
  sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list && \
  apt-get clean && \
  echo "**** install build packages ****" && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    python3-dev && \
  echo "**** install runtime packages ****" && \
  apt-get install -y \
    imagemagick \
    ghostscript \
    libldap-2.5-0 \
    libnss3 \
    libsasl2-2 \
    libxcomposite1 \
    libxi6 \
    libxrandr2 \
    libxkbfile-dev \
    libxslt1.1 \
    libxtst6 \
    python3-minimal \
    python3-pip \
    python3-pkg-resources \
    unrar && \
  echo "**** install calibre-web ****" && \
  # if [ -z ${CALIBREWEB_RELEASE+x} ]; then \
  #   CALIBREWEB_RELEASE=$(curl -sX GET "https://api.github.com/repos/janeczku/calibre-web/releases/latest" \
  #   | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  # fi && \
  curl -o \
    /tmp/calibre-web.tar.gz -L \
    https://ghproxy.com/https://github.com/janeczku/calibre-web/archive/${CALIBREWEB_RELEASE}.tar.gz && \
  mkdir -p \
    /app/calibre-web && \
  tar xf \
    /tmp/calibre-web.tar.gz -C \
    /app/calibre-web --strip-components=1 && \
  cd /app/calibre-web && \
  pip3 install --no-cache-dir -U -i https://pypi.tuna.tsinghua.edu.cn/simple\
    pip \
    wheel && \
  pip3 install --no-cache-dir -U --ignore-installed -i https://pypi.tuna.tsinghua.edu.cn/simple -r \
    requirements.txt -r \
    optional-requirements.txt && \
  echo "**** install calibre book ****" && \
  apt-get install -y \
    xz-utils \
    libgl1-mesa-glx \
    libxdamage1 \
    libegl1 \
    libxkbcommon0 \
    libopengl0 &&\
  rm -rf /app/calibre &&\
  mkdir -p /app/calibre &&\
  curl -o \
    /tmp/calibre.txz -L \
    https://ghproxy.com/https://github.com/kovidgoyal/calibre/releases/download/v${CALIBRE_RELEASE}/calibre-${CALIBRE_RELEASE}-x86_64.txz && \
  tar xf \
    /tmp/calibre.txz \
    -C /app/calibre &&\
  rm /tmp/calibre.txz &&\
  /app/calibre/calibre_postinstall &&\
  echo "***install kepubify" && \
  # if [ -z ${KEPUBIFY_RELEASE+x} ]; then \
  #   KEPUBIFY_RELEASE=$(curl -sX GET "https://api.github.com/repos/pgaskin/kepubify/releases/latest" \
  #   | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  # fi && \
  curl -o \
    /usr/bin/kepubify -L \
    https://ghproxy.com/https://github.com/pgaskin/kepubify/releases/download/${KEPUBIFY_RELEASE}/kepubify-linux-64bit && \
  chmod 755 /usr/bin/kepubify && \
  echo "**** cleanup ****" && \
  apt-get -y purge \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    python3-dev && \
  apt-get -y autoremove && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /root/.cache

#add local files
COPY root/ /

#ports and volumes
EXPOSE 8083
VOLUME /library /config /autoaddbooks
