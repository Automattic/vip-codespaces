FROM buildpack-deps:noble-curl@sha256:130fe02e4ba5e3b75a59e13385d0712f2debc246348ba27ecc10fcf3b2a92356

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        gettext \
        moreutils \
        runit \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && deluser --remove-home ubuntu

RUN \
    update-rc.d -f procps remove && \
    touch /etc/runit/no.emulate.sysv

ENTRYPOINT ["/lib/runit/runit-init"]
