FROM ubuntu:22.04

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV CONTAINER_USER ${USERNAME}

ENV LANG "C.UTF-8"
ENV CHARSET UTF-8
ENV LANG C.UTF-8
ENV LC_COLLATE C
ENV SHELL /bin/bash

RUN apt-get update && export DEBIAN_FRONTEND=noninteractive && yes | unminimize 2>&1 && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        bzip2 \
        ca-certificates \
        curl \
        dialog \
        dirmngr \
        gettext \
        gnupg2 \
        htop \
        iproute2 \
        jq \
        less \
        locales \
        lsb-release \
        lsof \
        man-db \
        manpages \
        manpages-dev \
        moreutils \
        nano \
        ncdu \
        net-base \
        net-tools \
        openssh-client \
        psmisc \
        procps \
        rsync \
        runit \
        software-properties-common \
        strace \
        subversion \
        sudo \
        tzdata \
        unzip \
        vim-tiny \
        wget \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

ADD rootfs /

RUN \
    groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd -s /bin/bash --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" && \
    echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

ENTRYPOINT ["/usr/local/bin/runit-wrapper"]
