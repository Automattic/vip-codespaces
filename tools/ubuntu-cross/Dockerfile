FROM --platform=${BUILDPLATFORM} tonistiigi/xx:master@sha256:03d51fee1471177a306eb2887d964055f3709d4599b79d26c5eca9d6016720c4 AS xx
FROM --platform=${BUILDPLATFORM} ubuntu:noble@sha256:84e77dee7d1bc93fb029a45e3c6cb9d8aa4831ccfcc7103d36e876938d28895b AS build
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
