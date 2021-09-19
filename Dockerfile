ARG ALPINE_IMAGE=alpine:3.13

FROM ${ALPINE_IMAGE} as build

WORKDIR /root/rtorrent

# Install build dependencies
RUN apk --no-cache add \
    bash \
    build-base \
    coreutils \
    gcompat \
    git \
    wget \
    linux-headers \
    python2 \
    python3

# Install Bazel
RUN apk --no-cache add \
    -Xhttps://dl-cdn.alpinelinux.org/alpine/edge/testing \
    bazel

# Checkout rTorrent sources from current directory
COPY . ./

# # Checkout rTorrent sources from Github repository
# RUN git clone https://github.com/jesec/rtorrent .

# Set architecture for .deb package
RUN if [[ `uname -m` == "aarch64" ]]; \
    then wget https://github.com/jesec/rtorrent/releases/download/v0.9.8-r14/rtorrent-linux-arm64; mv rtorrent-linux-arm64 rtorrent; \
    elif [[ `uname -m` == "x86_64" ]]; \
    then wget https://github.com/jesec/rtorrent/releases/download/v0.9.8-r14/rtorrent-linux-amd64; mv rtorrent-linux-amd64 rtorrent; \
    fi

# Now get the clean image
FROM ${ALPINE_IMAGE} as build-sysroot

WORKDIR /root


FROM ${ALPINE_IMAGE} as rtorrent

COPY --from=build /root/rtorrent/rtorrent /usr/bin/rtorrent
RUN chmod +x /usr/bin/rtorrent
RUN apk --no-cache add \
    ca-certificates \
    ncurses-terminfo-base
RUN adduser -h /home/download -s /sbin/nologin --disabled-password download
# Run as 1001:1001 user
ENV HOME=/home/download
USER 1001:1001

# rTorrent
ENTRYPOINT ["rtorrent"]
