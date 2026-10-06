FROM rust:1-bookworm AS build
# dh-p2p fork, multiport branch (several ports over one P2P session, timeouts
# instead of hangs, no panics on unknown realms), pinned to a commit.
ARG DH_P2P_REPO=https://github.com/EdwOK/dh-p2p
ARG DH_P2P_COMMIT=09e8a6689ee01fa2c32481bce1af4518cf3d6310
RUN git clone --branch multiport "$DH_P2P_REPO" /src \
    && git -C /src checkout "$DH_P2P_COMMIT"
WORKDIR /src
RUN cargo build --release

FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates jq \
    && rm -rf /var/lib/apt/lists/*
COPY --from=build /src/target/release/dh-p2p /usr/local/bin/dh-p2p
COPY run.sh /run.sh
RUN sed -i 's/\r$//' /run.sh && chmod +x /run.sh
CMD ["/run.sh"]
