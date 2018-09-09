FROM debian:jessie

ENV DEBIAN_FRONTEND noninteractive
ENV VERSION=0.6.8

WORKDIR /srv/

ADD scripts /srv/

RUN apt-get update && \
    apt-get install -y iptables wget unzip ipset && \
    wget "https://github.com/nadoo/glider/releases/download/v${VERSION}/glider-v${VERSION}-linux-amd64.zip" && \
    mkdir -p /srv/glider/ && \
    unzip "glider-v${VERSION}-linux-amd64.zip" -d /srv/glider/ && \
    apt-get remove -y wget unzip && \
    chmod +x /srv/*.sh && \
    chmod +x /srv/glider/glider && \
    rm -rf "glider-v${VERSION}-linux-amd64.zip"

VOLUME [ "/srv/glider/config" ]

ENTRYPOINT [ "/srv/start.sh" ]