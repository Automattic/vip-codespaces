FROM alpine:3.21.3@sha256:a8560b36e8b8210634f77d9f7f9efd7ffa463e380b75e2e74aff4511df3ef88c

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
