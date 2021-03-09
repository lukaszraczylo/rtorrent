ARG ALPINE_IMAGE=alpine:3.13

FROM ${ALPINE_IMAGE} as build

WORKDIR /root/rtorrent

# Install build dependencies
RUN apk --no-cache add \
    bash \
    wget

# # Checkout rTorrent sources from Github repository
# RUN git clone https://github.com/jesec/rtorrent .

# Set architecture for .deb package
RUN if [[ `uname -m` == "aarch64" ]]; \
    then wget https://github.com/jesec/rtorrent/releases/download/v0.9.8-r7/rtorrent-linux-arm64; mv rtorrent-linux-arm64 rtorrent; \
    elif [[ `uname -m` == "x86_64" ]]; \
    then wget https://github.com/jesec/rtorrent/releases/download/v0.9.8-r7/rtorrent-linux-amd64; mv rtorrent-linux-amd64 rtorrent; \
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
# Run as 1001:1001 user
ENV HOME=/home/download
USER 1001:1001

# rTorrent
ENTRYPOINT ["rtorrent"]
