FROM debian:8.0
MAINTAINER Arthur Axel fREW Schmidt <falcor2@afoolishmanifesto.com>

VOLUME ["/opt/var"]
EXPOSE 5000

ADD . /opt/app

ENV FALCOR2CONFVAL_PORT 5000
ENV FALCOR2CONFVAL_REMIND_PATH /opt/var/remind

WORKDIR /opt/app

RUN env DEBIAN_FRONTEND=noninteractive apt-get update \
 && env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    build-essential    \
    carton             \
    libexpat1-dev      \
    libxml2-dev        \
    libssl-dev         \
    openssl            \
    remind             \
    zlib1g-dev         \
 && carton install --deployment \
 && env DEBIAN_FRONTEND=noninteractive apt-get remove build-essential -y \
 && env DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
 && env DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cpanm local/cache local/man

CMD ["carton", "exec", "perl", "-Ilib", "bin/falcor2.pl"]
