FROM --platform=${BUILDPLATFORM} tonistiigi/xx:master@sha256:7e8c9d88e47741bb0d35981494920eee2857cd75a40193567fe6c1a16adf785d AS xx
FROM --platform=${BUILDPLATFORM} ubuntu:noble@sha256:186072bba1b2f436cbb91ef2567abca677337cfc786c86e107d25b7072feef0c AS build
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
