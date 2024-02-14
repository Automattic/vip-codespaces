FROM ubuntu:22.04

ARG USERNAME=vscode

ENV CONTAINER_USER ${USERNAME}
ENV LANG C.UTF-8
ENV CHARSET UTF-8
ENV LC_COLLATE C

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && yes | unminimize 2>&1 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gettext \
        gnupg \
        moreutils \
        netbase \
        runit \
        software-properties-common \
        subversion \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

RUN update-rc.d procps remove

ENTRYPOINT ["/lib/runit/runit-init"]
