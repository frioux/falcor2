FROM phusion/baseimage:0.9.16
MAINTAINER Arthur Axel fREW Schmdit <frioux@gmail.com>

CMD ["/sbin/my_init"]
VOLUME ["/opt/var", "/opt/log"]
EXPOSE 5000

ADD . /opt/app
ADD app.sh /etc/service/app/run
ADD log.sh /etc/service/app/log/run

ENV PERL5LIB lib:local/lib/perl5
ENV FALCOR2CONFVAL_PORT 5000
ENV FALCOR2CONFVAL_REMIND_PATH /opt/var/remind

WORKDIR /opt/app
RUN env DEBIAN_FRONTEND=noninteractive apt-get update \
 && useradd app \
 && chown 1000:1000 /opt/var \
 && env DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    build-essential    \
    carton             \
    daemontools        \
    libexpat1-dev      \
    libxml2-dev        \
    libssl-dev         \
    remind             \
    sudo               \
    zlib1g-dev         \
 && carton install --deployment \
 && env DEBIAN_FRONTEND=noninteractive apt-get remove build-essential -y \
 && env DEBIAN_FRONTEND=noninteractive apt-get autoremove -y \
 && env DEBIAN_FRONTEND=noninteractive apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* ~/.cpanm local/cache local/man
