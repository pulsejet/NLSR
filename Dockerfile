# syntax=docker/dockerfile:1

ARG NDN_CXX_VERSION=latest

FROM ghcr.io/named-data/ndn-cxx-build:${NDN_CXX_VERSION} AS build

ARG JOBS
ARG PSYNC_REPOSITORY=https://github.com/named-data/PSync
ARG PSYNC_VERSION=master

RUN <<EOF
    apt-get -Uy install --reinstall ca-certificates libboost-iostreams-dev
    rm -rf /var/lib/apt/lists/*
EOF

RUN <<EOF
    set -eux
    git clone --depth 1 --branch="${PSYNC_VERSION}" "${PSYNC_REPOSITORY}" psync
    cd psync
    ./waf configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --sharedstatedir=/var
    ./waf build
    ./waf install
    ldconfig
    cd -
    rm -rf PSync
EOF

RUN --mount=rw,target=/src <<EOF
    set -eux
    cd /src
    ./waf configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --sysconfdir=/etc \
        --localstatedir=/var \
        --sharedstatedir=/var
    ./waf build
    ./waf install

    mkdir -p /deps/debian
    touch /deps/debian/control
    cd /deps
    for binary in /usr/bin/nlsr /usr/lib/libPSync.so ; do
        dpkg-shlibdeps --ignore-missing-info "${binary}" -O \
            | sed -n 's|^shlibs:Depends=||p' | sed 's| ([^)]*),\?||g' >> deps.txt
    done
EOF


FROM ghcr.io/named-data/ndn-cxx-runtime:${NDN_CXX_VERSION} AS nlsr

COPY --link --from=build /usr/lib/libPSync.so* /usr/lib/
COPY --link --from=build /usr/bin/nlsr /usr/bin/
COPY --link --from=build /usr/bin/nlsrc /usr/bin/

RUN --mount=from=build,source=/deps,target=/deps \
    apt-get install -Uy --no-install-recommends $(cat /deps/*) \
    && rm -rf /var/lib/apt/lists/*

ENV HOME=/config
VOLUME /config
VOLUME /run/nfd

ENTRYPOINT ["/usr/bin/nlsr"]
CMD ["-f", "/config/nlsr.conf"]