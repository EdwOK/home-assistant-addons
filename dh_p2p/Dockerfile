FROM rust:1-alpine AS build
RUN apk add --no-cache git musl-dev
# dh-p2p fork, multiport branch (several ports over one P2P session, timeouts
# instead of hangs, no panics on unknown realms), pinned to a commit.
ARG DH_P2P_REPO=https://github.com/EdwOK/dh-p2p
ARG DH_P2P_COMMIT=09e8a6689ee01fa2c32481bce1af4518cf3d6310
RUN git clone --branch multiport "$DH_P2P_REPO" /src \
    && git -C /src checkout "$DH_P2P_COMMIT"
WORKDIR /src
# musl target: a single static binary, so the runtime image needs no libc extras.
RUN cargo build --release && strip target/release/dh-p2p

FROM alpine:3.22
# grep: run.sh needs GNU grep's --line-buffered (BusyBox grep lacks it).
RUN apk add --no-cache bash jq grep
COPY --from=build /src/target/release/dh-p2p /usr/local/bin/dh-p2p
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod +x /run.sh
CMD ["/run.sh"]
