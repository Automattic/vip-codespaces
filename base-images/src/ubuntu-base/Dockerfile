FROM buildpack-deps:noble-curl@sha256:0591c4ff26a20c9bd55f2531bc515396f6d356830bbe9e1136205dcabcf857cf

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
