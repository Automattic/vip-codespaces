FROM --platform=${BUILDPLATFORM} tonistiigi/xx:master@sha256:e38fcb938a3b7ee3e513de596bf6daa1e634335f9e4da890d8fdbd8ef36d5517 AS xx
FROM --platform=${BUILDPLATFORM} ubuntu:noble@sha256:728785b59223d755e3e5c5af178fab1be7031f3522c5ccd7a0b32b80d8248123 AS build
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
