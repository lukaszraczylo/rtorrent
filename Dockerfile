ARG ALPINE_IMAGE=alpine

FROM ${ALPINE_IMAGE} as build

WORKDIR /root/rtorrent

# Install build dependencies
RUN apk --no-cache add \
    build-base \
    cmake \
    git \
    linux-headers \
    ncurses-dev \
    ncurses-static \
    xmlrpc-c-dev

# Install Bazel 3 from edge testing repository
RUN apk --no-cache add \
    bazel3 \
    --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing

# Checkout rTorrent sources from current directory
COPY . ./

# # Checkout rTorrent sources from Github repository
# RUN git clone https://github.com/jesec/rtorrent .

# Alpine does not have or use libtinfo
RUN sed -i /ltinfo/d BUILD

# Build rTorrent
RUN bazel build

# Now get the clean image
FROM ${ALPINE_IMAGE} as rtorrent

# Install rTorrent built
COPY --from=build /root/rtorrent/bazel-bin/rtorrent /usr/local/bin

# Install runtime dependencies
RUN apk --no-cache add \
    ca-certificates \
    ncurses-terminfo-base

# Copy default configuration file to /etc/rtorrent
COPY --from=build /root/rtorrent/doc/rtorrent.rc /etc/rtorrent/

# Run as "nobody"
# Users should explicitly set UID/GID and/or grant privileges
USER nobody

# rTorrent
ENTRYPOINT ["rtorrent"]