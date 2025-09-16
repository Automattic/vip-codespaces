FROM --platform=${BUILDPLATFORM} tonistiigi/xx:master@sha256:7d5cbcc2c24fd4af0b555e51e7ff7282aad6d8a56275e06681a209237fd0becd AS xx
FROM --platform=${BUILDPLATFORM} ubuntu:noble@sha256:590e57acc18d58cd25d00254d4ca989bbfcd7d929ca6b521892c9c904c391f50 AS build
COPY --from=xx / /

RUN <<EOF
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends eatmydata
    eatmydata apt-get install -y --no-install-recommends clang make
    rm -rf /var/lib/apt/lists/*
    for i in linux/arm linux/arm64 linux/386 linux/amd64; do
        TARGETPLATFORM="${i}" xx-clang --setup-target-triple
        TARGETPLATFORM="${i}" eatmydata xx-apt-get install -y gcc g++ libc6-dev libstdc++-13-dev
    done
EOF

WORKDIR /src
