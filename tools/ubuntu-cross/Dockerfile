FROM --platform=${BUILDPLATFORM} tonistiigi/xx:master@sha256:7f82cfd583c0305afe20080361edf35bd7f7f6e286431718cc4036afc5e5d3ce AS xx
FROM --platform=${BUILDPLATFORM} ubuntu:noble@sha256:d1e2e92c075e5ca139d51a140fff46f84315c0fdce203eab2807c7e495eff4f9 AS build
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
