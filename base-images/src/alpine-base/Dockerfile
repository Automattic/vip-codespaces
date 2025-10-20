FROM alpine:3.22.2@sha256:4b7ce07002c69e8f3d704a9c5d6fd3053be500b7f1c69fc0d80990c2ad8dd412

ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=${USER_UID}

ENV CONTAINER_USER ${USERNAME}

RUN apk add --no-cache \
    runit \
    bash \
    openssh-client \
    gnupg \
    procps \
    lsof \
    htop \
    net-tools \
    psmisc \
    curl \
    wget \
    rsync \
    ca-certificates \
    unzip \
    zip \
    nano \
    vim \
    less \
    jq \
    libgcc \
    libstdc++ \
    krb5-libs \
    libintl \
    libssl3 \
    lttng-ust \
    tzdata \
    userspace-rcu \
    zlib \
    sudo \
    coreutils \
    sed \
    grep \
    which \
    ncdu \
    shadow \
    strace \
    mandoc man-pages \
    git \
    su-exec gettext subversion github-cli

ADD rootfs /

RUN \
    groupadd --gid "${USER_GID}" "${USERNAME}" && \
    useradd -s /bin/bash --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}" && \
    echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" && \
    chmod 0440 "/etc/sudoers.d/${USERNAME}"

ENV CHARSET UTF-8
ENV LANG C.UTF-8
ENV LC_COLLATE C

ENTRYPOINT ["/usr/local/bin/runit-wrapper"]
